module Api; module V1000
    
  class UsersController < BaseController
    
    skip_before_filter :authenticate, :only => [:create, :recover_password]
        
    def create

      @user = User.new(user_params)
      
      @user.password = User.generate_password
      
      if @user.save
        UserMailer.confirm_registration(@user).deliver_now
        create_registered_auth_token
        destroy_current_auth_token
        render json: {}
      else     
        render json: @user.errors.messages, status: :unprocessable_entity 
      end    
      
    end
    
    def profile
      if request.get?
        render json: current_user.as_json(only: [:id, :first_name, :middle_name, :last_name, :email, :gender, :avatar])
      elsif request.put?
        if current_user.update_attributes(user_update_params)      
          render json: {message: t('users.basic_information.update_success')}
        else     
          render json: current_user.errors.messages, status: :unprocessable_entity
        end
      end
    end

    def update_avatar
      avatar = params[:avatar];
      cropping_data = params[:avatar_cropping_data];
      current_user.avatar_cropping_data = cropping_data
      if cropping_data and not avatar then #crop existing avatar
        current_user.avatar.recreate_versions!
        render json: {avatar: current_user.avatar.as_json, message: t('users.update_avatar.success')}
      else #update and/or crop avatar 
        current_user.avatar = params[:avatar]
        if current_user.save
          current_user.reload
          render json: {avatar: current_user.avatar.as_json, message: t('users.update_avatar.success')}
        else     
          render json: current_user.errors.messages, status: :unprocessable_entity
        end
      end
    end
    
    def recover_password
      
      if params[:email].blank?
        render json: {message: t('users.recover_password.email_required')}, status: :unprocessable_entity and return
      end
      
      user = User.find_by email: params[:email]
      
      if user.nil?
        render json: {message: t('users.recover_password.non_existing_account')}, status: :unprocessable_entity
      else
        recovering_password = User.generate_password
        user.set_recovering_password(recovering_password)
        UserMailer.recover_password(user).deliver_now
        render json: {message: t('users.recover_password.recovering_password_sent')}
      end
      
    end
    
    def friends
      render json: current_user.top_friends(100), only: [:id, :first_name, :last_name, :middle_name, :score, :avatar], include: [:level]
    end
    
    def add_point_to_bag
      Point.add_point_for_user(params[:point_id], current_user.id)
      render json: {message: t('users.add_point_to_bag.added')}
    end
    
    def deactivate_point_in_bag
      review = current_user.reviews.find_by(point_id: params[:point_id])
      review.update_attribute :is_active, false 
      render json: {message: t('users.deactivate_point_in_bag.deactivated')}
    end
    
    private
    
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email)
    end
    
    def user_update_params
      params.require(:user).permit(:first_name, :middle_name, :last_name, :password, :password_confirmation, :gender, :avatar)
    end
        
  end
  
end;end
