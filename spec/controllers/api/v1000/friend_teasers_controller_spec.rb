require 'spec_helper'

describe Api::V1000::FriendTeasersController do
  
  describe "GET index" do
    
    it "returns 5 most selected active teasers" do
      
      sign_in User.one
      
      t1, t2, t3, t4, t5, t6 = FriendTeaser.has([
                                                  {selected_times: 1},
                                                  {selected_times: 2},
                                                  {selected_times: 3},
                                                  {selected_times: 4},
                                                  {selected_times: 5},
                                                  {selected_times: 6},
                                                ])
      
      t6.update_attributes is_active: false
      
      get :index
      
      should respond_with 200
      
      expect(json_response.count).to be 5
      expect(json_response.map(&:id)).to eq [t5, t4, t3, t2, t1].map(&:id)
      
      response_teaser = json_response.first
      database_teaser = FriendTeaser.find(response_teaser.id)
      
      expect(response_teaser.teasing_phase).to eq database_teaser.teasing_phase
      expect(response_teaser.is_active).to eq database_teaser.is_active
      expect(response_teaser.selected_times).to eq database_teaser.selected_times
      
    end
    
  end
  
end