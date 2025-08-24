module Api;module V1000

  class UserUiActionsController < BaseController
    
    skip_filter :authenticate
    
    def create
      
      UserUiAction.create!(user_ui_action_params.merge(user_id: (current_user.nil? ? nil : current_user.id), ip_address: request.remote_ip))
      
      render json: {}
          
    end
    
    private
  
    def user_ui_action_params
      params.require(:user_ui_action).permit(:action, :action_data, :action_time, :view, :device)
    end
      
  end
  
end;end