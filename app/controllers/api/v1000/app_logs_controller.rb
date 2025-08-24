module Api;module V1000

  class AppLogsController < BaseController
    
    skip_filter :authenticate, only: [:create]
    
    def create
      
      app_log = AppLog.new(
        log_type: app_log_params[:log_type],
        content: app_log_params[:content],
        device: app_log_params[:device]
      )
      
      app_log.save
      
      AdministratorMailer.delay.notify("New log from client", app_log.to_json)
      
      render json: {}
          
    end
    
    private
  
    def app_log_params
      params.require(:app_log).permit(:log_type, :content, :device)
    end
      
  end
  
end;end