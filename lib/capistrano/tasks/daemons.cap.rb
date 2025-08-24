namespace :daemons do

  def daemons_roles
    fetch(:delayed_job_server_role, :app)
  end

  desc 'Stop daemons'
  task :stop do
    on roles(daemons_roles) do
      within release_path do    
        with rails_env: fetch(:rails_env) do
          execute :rake, 'daemons:stop'
        end
      end
    end
  end

  desc 'Start daemons'
  task :start do
    on roles(daemons_roles) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'daemons:start'
        end
      end
    end
  end

  desc 'Restart daemons'
  task :restart do
    on roles(daemons_roles) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'daemons:stop'
          execute :rake, 'daemons:start'
        end
      end
    end
  end

end