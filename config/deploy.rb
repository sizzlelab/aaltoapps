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

  desc "Run all tasks needed for a deployment." +
       " Specify git branch with BRANCH (default: master)." +
       " Skip tasks with EXCEPT=task1,task2,..."
  task :deploy do
    # if branch specified and there are custom values for the branch, use them
    (branch_config[ENV['BRANCH']] || {}).each { |key,val| set key, val }

    # list of tasks to skip
    except = (ENV['EXCEPT'] || '').split(/[\s,]+/)

    tasks = %w[
      vlad:setup
      vlad:update
      vlad:bundle:install
      vlad:copy_config_files
      vlad:compile_assets
      vlad:migrate
      vlad:start_app
    ]
    (tasks - except).each do |name|
      Rake::Task[name].invoke
    end
  end

end
