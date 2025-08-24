require 'spec_helper'

describe Api::V1000::SoundsController do
  
  describe "GET #show" do
    
    it "returns sound data" do
      
      sound = FactoryBot.create :sound
      
      get :show, id: sound.id, version: sound.updated_at.to_i, format: 'mp3'
      
      should respond_with 200
      
      expect(response.body).to eq sound.mp3
      
    end
    
  end
  
end