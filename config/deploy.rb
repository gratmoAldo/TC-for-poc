set :application, "content_hub_v2"
set :user, "ubuntu"
set :deploy_to, "/home/ubuntu/rails/#{application}"
set :deploy_via, :remote_cache
# set :use_sudo, false
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "here")] 

# :scm = `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :scm, :git
set :repository,  "git://github.com/hervenln/TC-for-poc.git"
set :branch, "master"
set :checkout, "export"
set :rails_env, :production
# set :svn_username, "jim"
# set :svn_password, "password"

# role :web, "innovation1.dctmlabs.com"                          # Your HTTP server, Apache/etc
# role :app, "innovation1.dctmlabs.com"                          # This may be the same as your `Web` server
# role :db,  "innovation1.dctmlabs.com", :primary => true # This is where Rails migrations will run

# server "innovation1.dctmlabs.com", :app, :web, :db, :primary => true
# server "hl400.local", :app, :web, :db, :primary => true
server "ec2-50-17-158-115.compute-1.amazonaws.com", :app, :web, :db, :primary => true

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    desc "Restart Application and daemons"
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    run "#{File.join(current_path,'script','daemons')} restart"
  end
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
#    run "ln -nfs #{shared_path}/config/apple_push_notification_development.pem #{release_path}/config/apple_push_notification_development.pem"
    run "ln -nfs #{shared_path}/config/apple_push_notification_production.pem #{release_path}/config/apple_push_notification_production.pem"
  end
  task :seed, :roles => :app, :except => { :no_release => true } do
    run "export RAILS_ENV=development;cd #{current_path}; rake db:seed --trace"
    # run "export RAILS_ENV=production;cd #{current_path};echo $RAILS_ENV >env.txt"
  end
end

after "deploy", "deploy:cleanup" # keeps only last 5 releases
after 'deploy:update_code', "deploy:symlink_shared"
