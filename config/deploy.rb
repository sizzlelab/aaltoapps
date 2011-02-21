set :application, "aaltoapps"
set :domain, "aaltoapps@79.125.124.244"
set :deploy_to, "/mnt/app/aaltoapps/"
set :repository, 'git://github.com/sizzlelab/aaltoapps.git'
set :rake_cmd, 'source /usr/local/lib/rvm ; rake'

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
    run "ln -s #{shared_path}/system/products /mnt/app/aaltoapps/current/public/products"
  end

  desc "Bubble gum for bundler and rvm, hope this gets a gem from the bundle/rvm folks"
  remote_task :bundle_install do
    # loads RVM, which initializes environment and paths
    init_rvm = "source /usr/local/lib/rvm"

    # ya know, get to where we need to go
    # ex. /var/www/my_app/releases/12345
    goto_app_root = "cd #{release_path}"

    # run bundle install with explicit path and without test dependencies
    bundle_install = "bundle install --without test"

    # actually run all of the commands via ssh on the server
    run "#{init_rvm} && #{goto_app_root} && #{bundle_install}"
  end

  desc "Run all tasks needed for a deployment"
  task :deploy do
    Rake::Task['vlad:setup'].invoke
    Rake::Task['vlad:update'].invoke
    Rake::Task['vlad:bundle_install'].invoke
    Rake::Task['vlad:copy_config_files'].invoke
    Rake::Task['vlad:link_phogos'].invoke
    Rake::Task['vlad:migrate'].invoke
    Rake::Task['vlad:start_app'].invoke
  end

end

