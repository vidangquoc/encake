module Authenticable

  def sign_in(user, params = {})
    
    anonymous_token  = (request.headers['HTTP_AUTH_TOKEN'] || request.headers['AUTH_TOKEN']).to_s
    
    token = nil
    
    if !anonymous_token.blank?
      auth_token = AuthenticationToken.find_active(nil, anonymous_token)
      if auth_token && user.id
        auth_token.update_attributes user_id: user.id, user_type: 'active'
        token = anonymous_token
      end
    end
    
    if token.nil?
      params[:user_type] = user.id.nil? ? 'anonymous' : 'active'
      params[:ip_address] = request.remote_ip
      token = AuthenticationToken.create_for_user(user, params)
    end
    
    @current_user = user
    token
    
  end
  
  def sign_out(auth_token)
    AuthenticationToken.deactivate(@current_user.id, auth_token) if @current_user.present?
    @current_user = nil
  end
  
  def current_user
    @current_user ||= find_user_by_auth_headers
  end
  
  def authenticate
    render json: {message: "Not authenticated!"}, status: :unauthorized if current_user.nil?
  end
  
  def create_registered_auth_token
    begin
      AuthenticationToken.create_for_user(@user, user_type: 'just_registered')
    rescue Exception => exeption #ignore any exception
      ExceptionNotifier.notify_exception(exception, :env => request.env, :data => {:message => "unable to create registed auth token"})
    end
  end

  def destroy_current_auth_token
    encrypted_auth_token  = (request.headers['HTTP_AUTH_TOKEN'] || request.headers['AUTH_TOKEN']).to_s
    token = AuthenticationToken.find_by_encrypted_token(encrypted_auth_token)
    token.destroy if !token.nil?
  end
  
  private
  
  def find_user_by_auth_headers
    
    user_id = request.headers['HTTP_AUTH_USER_ID'] || request.headers['AUTH_USER_ID'] || params[:auth_user_id]
      
    auth_token  = (request.headers['HTTP_AUTH_TOKEN'] || request.headers['AUTH_TOKEN'] || params[:auth_token]).to_s
    
    token = user = nil
    
    if user_id.present?
      
      user = User.find_by id: user_id
      
      token = AuthenticationToken.find_active(user.id, auth_token) if user.present?
      
    else
    
      token = AuthenticationToken.find_active(nil, auth_token)
      
    end
    
    if token
      token.renew
      user
    else
      nil
    end
  
  end
  
end