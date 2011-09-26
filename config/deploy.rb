set :application, "aaltoapps"
set :domain, "aaltoapps@aaltoapps.com"
set :deploy_to, "/mnt/app/aaltoapps/"
set :repository, 'git://github.com/sizzlelab/aaltoapps.git'

# alternate settings for deploying different branches from repository
set :branch_config, {
  'demo' => {
    :deploy_to => "/mnt/app/aaltoapps-demo",
    :revision => "origin/demo",
  },
  'uidev' => {
    :deploy_to => "/mnt/app/aaltoapps-uidev",
    :revision => "origin/uidev",
  },
}

set :rbenv_path, "~/.rbenv/bin:~/.rbenv/shims"
set :bundle_cmd, %Q(PATH="#{rbenv_path}:$PATH" bundle)
set :rake_cmd, "#{bundle_cmd} exec rake"

set :shared_paths, shared_paths
  .except('system')
  .merge({
    'system/products' => 'public/products',
    'system/assets'   => 'public/assets',
  })
set :config_files, ['database.yml', 'aaltoapps_config.yml']

require "bundler/vlad"

namespace :vlad do
  desc "Copy config files from shared/config to release dir"
  remote_task :copy_config_files, :roles => :app do
    config_files.each do |filename|
      run "cp #{shared_path}/config/#{filename} #{release_path}/config/#{filename}"
    end
  end

  desc "Precompile assets"
  remote_task :compile_assets, :roles => :app do
    run "cd #{release_path} && #{rake_cmd} RAILS_ENV=#{rails_env} assets:precompile"
  end

  desc "Clean up asset directory and precompile assets locally"
  task :compile_assets_locally => %w[assets:clean assets:precompile]

  desc "Upload locally compiled assets"
  remote_task :upload_assets, :roles => :app do
    rsync 'public/assets', "#{target_host}:#{release_path}/public/assets"
  end

  multitask :concurrent_tasks => %w[
    vlad:remote_tasks
    vlad:compile_assets_locally
  ]

  task :remote_tasks => %w[
    vlad:setup
    vlad:update
    vlad:bundle:install
    vlad:copy_config_files
    vlad:migrate
  ]

  desc "Run all tasks needed for a deployment.
       Specify git branch with BRANCH (default: master).
       To compile assets concurrently on local computer,
       set COMPILE_ASSETS=local and make sure that the local copy
       of the application is at the same version as the one
       that is to be deployed.".cleanup
  task :deploy do
    # if branch specified and there are custom values for the branch, use them
    (branch_config[ENV['BRANCH']] || {}).each { |key,val| set key, val }

    if ENV['COMPILE_ASSETS'] =~ /^local/i
      Rake::Task['vlad:concurrent_tasks'].invoke
      Rake::Task['vlad:upload_assets'].invoke
    else
      Rake::Task['vlad:remote_tasks'].invoke
      Rake::Task['vlad:compile_assets'].invoke
    end

    Rake::Task['vlad:start_app'].invoke
  end

  task :deploy_using_local_asi do
    remote_task :copy_config_files do
      asi_url = 'http://localhost:3000'
      run %Q|sed -i -e 's/^\\( *\\(ssl_\\)\\?asi_url:\\) *"http.*"/\\1 "#{asi_url}"/' #{release_path}/config/#{filename}|
    end

    Rake::Task['vlad:deploy'].invoke
  end

end
