module Api;module V1000
  
  class UserActionsController < BaseController
    
    def update_teaser
      
      action = UserAction.find(params[:user_action_id])
      
      action.data[:teaser_id] = params[:teaser_id].to_i
      
      action.save
      
      action.pass_friend_teaser_to_notifications
      
      FriendTeaser.increase_selected_times(params[:teaser_id].to_i)
      
      render json: {}
      
    end
    
  end
  
end;end