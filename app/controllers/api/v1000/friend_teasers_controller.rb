module Api;module V1000

  class FriendTeasersController < BaseController
  
    def index
      render json: FriendTeaser.where(is_active:true).limit(5).order('selected_times DESC')
    end
    
  end

end;end
