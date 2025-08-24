require 'spec_helper'

describe Api::V1000::UserUiActionsController do
 
  describe "POST #create" do
    
    it "logs the user ui action to the database with correct data" do
      
      user = sign_in_a_user
      
      data = {action: 'click_on_something', action_data: "some string", action_time: DateTime.now.strftime('%Q'), view: 'someview', device: 'some device'}
      
      post :create, user_ui_action: data
      
      should respond_with 200
      
      action = UserUiAction.first
      
      expect(action).not_to be nil
      expect(action.user_id).to be user.id
      expect(action.action).to eq data[:action]
      expect(action.action_data).to eq data[:action_data]
      expect(action.action_time).to eq data[:action_time].to_i
      expect(action.view).to eq data[:view]
      expect(action.device).to eq data[:device]
      expect(action.ip_address).to eq request.remote_ip
      
    end
    
    it "allows anonymous logs" do
      
      data = {action: 'click_on_something', action_data: "some string", action_time: DateTime.now.strftime('%Q'), view: 'someview', device: 'some device'}
      post :create, user_ui_action: data
      
      should respond_with 200
      action = UserUiAction.first
      
      expect(action.user_id).to be nil
      
    end
    
  end
  
end