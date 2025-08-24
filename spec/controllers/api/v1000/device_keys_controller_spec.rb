require 'spec_helper'

describe Api::V1000::DeviceKeysController do
  
  before :each do
    @user = sign_in_a_user
  end
  
  describe "POST create" do
    
    before :each do
      @device_key_data = {user_id: @user.id, platform: 'android', key: 'a_new_device_key', old_key: 'old_key_on_the_device'}
    end
    
    context "all data is valid" do
      
      before :each do
        post :create, device_key: @device_key_data
      end
      
      it{should respond_with 200}
      
      it "returns the device_key object" do
        
        expect(json_response.user_id).to eq @device_key_data[:user_id]
        expect(json_response.platform).to eq @device_key_data[:platform]
        expect(json_response.key).to eq @device_key_data[:key]
        
      end
        
    end
    
    context "not data is valid" do
      
      before :each do
        post :create, device_key: @device_key_data.merge({key: ''})
      end
      
      it{should respond_with 422}
      
      it "returns the error message" do
        
        expect(json_response.key).to include validation_error_on('device_key.key.blank')
        
      end
        
    end
    
  end

end