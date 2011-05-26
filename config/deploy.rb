set :application, "aaltoapps"
set :domain, "aaltoapps@79.125.124.244"
set :deploy_to, "/mnt/app/aaltoapps/"
set :repository, 'git://github.com/sizzlelab/aaltoapps.git'
set :rake_cmd, %q(bash -c 'source /usr/local/lib/rvm ; bundle exec rake "$@"')

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

# config/deploy.rb
# ...&nbsp;
set :config_files, ['database.yml', 'aaltoapps_config.yml']
namespace :vlad do
  desc "Copy config files from shared/config to release dir"
  remote_task :copy_config_files, :roles => :app do
    config_files.each do |filename|
      run "cp #{shared_path}/config/#{filename} #{release_path}/config/#{filename}"
    end
  end

  desc "Link product photos"
  remote_task :link_photos, :roles => :app do
    run "ln -s #{shared_path}/system/products #{release_path}/public/products"
  end

  desc "Bubble gum for bundler and rvm, hope this gets a gem from the bundle/rvm folks"
  remote_task :bundle_install do
    # loads RVM, which initializes environment and paths
    init_rvm = "source /usr/local/lib/rvm"

    # ya know, get to where we need to go
    # ex. /var/www/my_app/releases/12345
    goto_app_root = "cd #{release_path}"

    # run bundle install with explicit path and without test dependencies
    bundle_install = "bundle install --without development test"

    # actually run all of the commands via ssh on the server
    run "bash -c '#{init_rvm} && #{goto_app_root} && #{bundle_install}'"
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
      vlad:bundle_install
      vlad:copy_config_files
      vlad:link_photos
      vlad:migrate
      vlad:start_app
    ]
    (tasks - except).each do |name|
      Rake::Task[name].invoke
    end
  end

end
