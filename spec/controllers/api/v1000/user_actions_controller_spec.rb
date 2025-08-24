require 'spec_helper'

describe Api::V1000::UserActionsController do
  
  describe "PUT #update_teaser" do
    
    before :each do
      
      user = FactoryBot.create :user
      level = FactoryBot.create :level
      @teaser = FactoryBot.create :friend_teaser
      @user_action = FactoryBot.create :user_action, user: user, data: {old_level_id: level.id, new_level_id: level.id, score_change: 3}
      @user_action.has_3_notifications
      
      sign_in user
      
    end
    
    it "returns ok status" do
      put :update_teaser, user_action_id: @user_action.id, teaser_id: @teaser.id
      should respond_with 200
    end
    
    it "stores teaser_id in the action" do
      
      put :update_teaser, user_action_id: @user_action.id, teaser_id: @teaser.id
      
      expect(@user_action.reload.data.fetch(:teaser_id)).to eq @teaser.id
      
    end
    
    it "stores teaser_id in the associated notifications" do
      
      put :update_teaser, user_action_id: @user_action.id, teaser_id: @teaser.id
      
      @user_action.reload.notifications.each do |notif|
        expect(notif.data.fetch(:teaser_id)).to be @teaser.id
      end
      
    end
    
    it "increases the selected times of the teaser" do
      
      put :update_teaser, user_action_id: @user_action.id, teaser_id: @teaser.id
      
      expect{put :update_teaser, user_action_id: @user_action.id, teaser_id: @teaser.id}.to change{@teaser.reload.selected_times}.by(1)
      
    end
    
  end
  
end