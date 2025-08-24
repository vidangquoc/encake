namespace :rpush do

  def rpush_roles
    fetch(:delayed_job_server_role, :app)
  end

  desc 'Stop rpush'
  task :stop do
    on roles(rpush_roles) do
      within release_path do    
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, 'bin/rpush', :stop, "-e #{fetch(:rails_env)}"
        end
      end
    end
  end

  desc 'Start rpush'
  task :start do
    on roles(rpush_roles) do
      within release_path do    
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, 'bin/rpush', :start, "-e #{fetch(:rails_env)}"
        end
      end
    end
  end

  desc 'Restart daemons'
  task :restart do
    on roles(rpush_roles) do
      within release_path do    
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, 'bin/rpush', :start, "-e #{fetch(:rails_env)}"
          execute :bundle, :exec, 'bin/rpush', :stop, "-e #{fetch(:rails_env)}"
          execute :bundle, :exec, 'bin/rpush', :start, "-e #{fetch(:rails_env)}"
        end
      end
    end
  end
  
  desc 'Create (or update) apps'
  task :create_apps do
    on roles(rpush_roles) do
      within release_path do    
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:rpush:create_apps"
        end
      end
    end
  end

end