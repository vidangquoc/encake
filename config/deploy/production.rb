set :deploy_to, "/home/deployer/www/enetwork_public"
set :repo_url,  'git@bitbucket.org:vidaica/encake.git'
set :stage, :production
set :branch, 'master'
set :ssh_options, { user: 'deployer' }

role :app, 'encake.com'
role :web, 'encake.com'
role :db, 'encake.com'
role :worker, 'encake.com'