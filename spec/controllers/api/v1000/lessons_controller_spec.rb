require 'spec_helper'

describe Api::V1000::LessonsController do

  describe "GET show" do
    
    it "returns the lesson with processed content" do
      
      @user = User.one
      
      sign_in User.one
      
      lesson = Lesson.one
      
      get :show, id: lesson.id
      
      should respond_with 200
      
      expect(json_response.id).to eq lesson.id
      expect(json_response.content).to eq lesson.process_content_for_show
      
    end
    
  end

end