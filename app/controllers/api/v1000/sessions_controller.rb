module Api;module V1000

  class SessionsController < BaseController
    
    skip_before_filter :authenticate, :only => [:create_anonymous, :create, :authenticate_by_token]
    
    def create_anonymous
      user = User.new
      user.auth_token = sign_in(user)
      render json: user, methods: :auth_token
    end
    
    def create
      
      email = params[:user][:email]
      password = params[:user][:password]
      
      if email.blank? or password.blank?
        user=User.new
        user.errors.add :base, :signin_email_and_password_required
        render json: {message: user.errors[:base].first}, status: :unprocessable_entity
        return
      end
      
      user = User.authenticate(email,password)
      
      if user.nil?
        user = User.authenticate_by_recovering_password(email, password)
      end
  
      if !user.nil?
        
        if not user.is_status?(:active)
          user.activate
        end
        
        user.auth_token = sign_in(user)
        
        render json: user.as_json(only: [:id, :first_name, :last_name] , methods: :auth_token) 
        
      else
        user=User.new
        user.errors.add :base, :signin_invalid
        render json: {message: user.errors[:base].first}, status: :unprocessable_entity
      end
      
    end
    
    def authenticate_by_token
      
      user_id = params[:user][:user_id]
      auth_token = params[:user][:auth_token]
      user = User.find_by(id: user_id)
      
      if !user.nil? && AuthenticationToken.find_active(user.id, auth_token)
        user.auth_token = auth_token
        render json: user, methods: :auth_token
      else
        render json: {message: "Unauthorized!"}, status: :unauthorized
      end
      
    end
    
    def destroy
      token = params[:id]
      sign_out(token)
      head 204
    end
      
  end

end;end