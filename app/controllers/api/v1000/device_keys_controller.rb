module Api;module V1000

  class DeviceKeysController < BaseController
    
    def create
      
      result = DeviceKey.create_or_update_key(current_user.id, device_key_params[:platform], device_key_params[:old_key], device_key_params[:key])
  
      if result[:saved]
        render json: result[:device_key]
      else
        render json: result[:device_key].errors.messages, status: :unprocessable_entity
      end
        
    end
    
    private
    
    def device_key_params
      params.require(:device_key).permit(:user_id, :platform, :key, :old_key)
    end
    
  end

end;end