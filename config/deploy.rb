# config valid only for Capistrano 3.1
lock '3.5.0'

set :application, 'encake'
set :rails_env, 'production'


set :delayed_job_server_role, :worker
set :delayed_job_args, "-n 1"

after 'deploy:publishing', 'deploy:restart'
after "deploy:restart", "rpush:create_apps"
after "deploy:restart", "delayed_job:restart"
#after "deploy:restart", "daemons:start"
#after "deploy:restart", "rpush:start"
after "deploy:restart", "deploy:cleanup"

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/constants.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets tmp/backup vendor/bundle public/system public/pron public/app}

# Default value for default_env is {}
#set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3


