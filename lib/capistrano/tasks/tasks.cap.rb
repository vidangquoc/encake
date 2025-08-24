namespace :deploy do
#
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

#  after :publishing, :restart
#
#  after :restart, :clear_cache do
#    on roles(:web), in: :groups, limit: 3, wait: 10 do
#      # Here we can do anything such as:
#      # within release_path do
#      #   execute :rake, 'cache:clear'
#      # end
#    end
#  end
#
end

namespace :deploy_custom do    

  desc "Upload configuration files"
  task :upload_configuration_files do
    on roles(:web) do
      upload!(File.expand_path('config/database.yml'), "#{ deploy_to }/shared/config/database.yml")
      upload!(File.expand_path('config/constants.yml'), "#{ deploy_to }/shared/config/constants.yml")
    end    
  end
  
end