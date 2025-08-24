set :deploy_to, "/home/vidaica/deployed_projects/enetwork_public"
set :repo_url,  "file:///home/vidaica/deployed_projects/repositories/enetwork_public"
set :stage, :local
set :branch, 'development'
set :ssh_options, { user: 'vidaica' }
#set :default_env, {
#  rvm_bin_path: '/home/vidaica/.rvm/bin',
#  GEM_HOME: '/home/vidaica/.rvm/gems/ruby-2.0.0-p353@rails4',
#  GEM_PATH: "/home/vidaica/.rvm/gems/ruby-2.0.0-p353@rails4:/home/vidaica/.rvm/gems/ruby-2.0.0-p353@global",
#  BUNDLE_GEMFILE: release_path + "Gemfile",
#  PATH: "/home/vidaica/.rvm/gems/ruby-2.0.0-p353@rails4/bin/:$PATH",
#}
#set :rvm_ruby_version, 'ruby-2.0.0-p353'

role :app, 'localhost'
role :web, 'localhost'
role :db, 'localhost'
role :worker, 'localhost'
