namespace :cleaner do
  
  desc 'Clear application log table'
  task :clear_app_logs do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do          
          execute :rake, "db:clear_app_logs"
        end
      end
    end
  end
  
  desc 'Clear failed delayed jobs that reach max attemps and older than one month'
  task :clear_failed_jobs do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do          
          execute :rake, "db:clear_failed_jobs"
        end
      end
    end
  end
  
  desc 'Clear cache files'
  task :clear_cache do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do          
          execute :rake, "cache:clear"
        end
      end
    end
  end
  
  desc 'Clear user ui actions that are older than one week'
  task :clear_user_ui_actions do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do          
          execute :rake, "db:clear_user_ui_actions"
        end
      end
    end
  end
  
  desc 'Clear slow queries table'
  task :clear_slow_queries do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do          
          execute :rake, "db:clear_slow_queries"
        end
      end
    end
  end
  
  desc 'Clear slow requests table'
  task :clear_slow_requests do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do          
          execute :rake, "db:clear_slow_requests"
        end
      end
    end
  end

  desc 'Clear all'
  task :clear_all do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:clear_app_logs"
          execute :rake, "db:clear_failed_jobs"
          execute :rake, "cache:clear"
          execute :rake, "db:clear_user_ui_actions"
          execute :rake, "db:clear_slow_queries"       
          execute :rake, "db:clear_slow_requests"
        end
      end
    end
  end

end