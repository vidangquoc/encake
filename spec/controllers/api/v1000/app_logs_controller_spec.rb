require 'spec_helper'

describe Api::V1000::AppLogsController do
  
  describe "POST create" do
    
    it "creates a log in database with correct data" do
      
      log_data = {log_type: "Any Type", content: "Some Content", device: "Some Device"}
      
      post :create, app_log: log_data
      
      should respond_with 200
      
      app_log = AppLog.first
      expect(app_log).not_to be nil
      expect(app_log.log_type).to eq log_data[:log_type]
      expect(app_log.content).to eq log_data[:content]
      expect(app_log.device).to eq log_data[:device]
      
    end
    
  end
  
end