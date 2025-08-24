require_relative '../spec_helper'

describe UserAction do
  
  describe "methods" do
    
    before :each do
        
      @user = User.one
      @friend1, @friend2, @friend3 = 3.Users
      @user.has_friendships([{friend_id: @friend1.id}, {friend_id: @friend2.id}, {friend_id: @friend3.id}])
      @level1, @level2, @level3 = 3.Levels
      
      @user_action = UserAction.new(
                                   user_id: @user.id,
                                   data: {
                                     old_level_id: @level1.id,
                                     new_level_id: @level1.id,
                                     score_change: 0
                                    }
                                  )
      
    end
    
    describe "process" do
      
      context "user's level has gone up" do      

        it "creates a 'ReachNewLevel' event" do
          
          @user_action.data = @user_action.data.merge({old_level_id: @level2.id, new_level_id: @level3.id})
          
          @user_action.save # will call #process method
          
          event = UserReachNewLevelEvent.first
          
          expect(event.from_action_id).to be @user_action.id
          
          expect(event.data[:new_level_id]).to be @level3.id
          
        end
        
      end
      
      context "the user overcomes friends" do
        
        it "creates 'OvercomeFriend' events do" do
          
          [@friend1, @friend2, @friend3, @user].serial_update score: [1,2,3,3]
          
          @user_action.data = @user_action.data.merge({score_change: 2, teaser_id: 1}) # by adding 2 score to reach new score of 3, user has overcome @friend1 and @friend2
          
          @user_action.save # will call #process method
          
          expect(UserOvercomeFriendEvent.count).to be 2
          expect(UserOvercomeFriendEvent.all.map(&:from_action_id).uniq).to eq [@user_action.id]          
          expect(UserOvercomeFriendEvent.all.map{|event| event.data[:friend_id]}.sort).to eq([@friend1.id, @friend2.id].sort)
          expect(UserOvercomeFriendEvent.all.map{|event| event.data[:score_diff]}.sort).to eq([1, 2].sort)
          
          #pass teaser_id to notifications
          expect(NotificationOvercomeFriend.all.map{|event| event.data[:teaser_id]}.uniq).to eq([1])
          
        end
        
      end
      
    end
    
    describe "overcome_friends" do
      
      it "returns overcome friends" do
        
        [@friend1, @friend2, @friend3, @user].serial_update score: [1,2,3,3]          
        @user_action.data = @user_action.data.merge({score_change: 2}) # by adding 2 score to reach new score of 3, user has overcome @friend1 and @friend2
        
        expect(@user_action.overcome_friends.map(&:id).sort).to eq [@friend1.id, @friend2.id].sort
        
      end
      
    end
    
    describe 'pass_friend_teaser_to_notifications' do
      
      before :each do
        [@friend1, @friend2, @friend3, @user].serial_update score: [1,2,3,3]
        @user_action.data = @user_action.data.merge({
                                                      score_change: 2, # by adding 2 score to reach new score of 3, user has overcome @friend1 and @friend2
                                                      old_level_id: @level2.id,
                                                      new_level_id: @level3.id,
                                                    }) 
        @user_action.save
      end
      
      it "passes its friend_teaser to associate notifications" do
        
        expect(NotificationOvercomeFriend.count).to be > 0
        
        @user_action.data[:teaser_id] = 1
        
        @user_action.pass_friend_teaser_to_notifications
        
        expect(NotificationOvercomeFriend.all.map{|notif| notif.data[:teaser_id]}.uniq).to eq [1]
        
      end
      
      it "does not pass friend_teaser to notifications not of type NotificationOvercomeFriend" do
        
        other_notifications = Notification.all.select{|notif| ! notif.instance_of?(NotificationOvercomeFriend)}
        
        expect(other_notifications.count).to be > 0
        
        @user_action.data[:teaser_id] = 1
        
        @user_action.pass_friend_teaser_to_notifications
        
        expect(other_notifications.map{|notif| notif.reload.data[:teaser_id]}.uniq).to eq [nil]
        
      end
      
      it "does not pass friend_teaser if the notifications already had a friend_teaser" do
        
        notification = NotificationOvercomeFriend.first
        notification.data[:teaser_id] = 100
        notification.save
        
        @user_action.data[:teaser_id] = 1
        
        @user_action.pass_friend_teaser_to_notifications
        
        expect(notification.reload.data[:teaser_id]).to be 100
        
      end
      
      it "sets 'defer_until' of notifications to present" do
        
        notification = NotificationOvercomeFriend.first
        notification.defer_until = 5.minutes.from_now
        notification.save
        
        @user_action.data[:teaser_id] = 1
        
        @user_action.pass_friend_teaser_to_notifications
        
        now = DateTime.now
        defered_time = notification.reload.defer_until
        
        expect(defered_time.to_i).to be > now.to_i - 3
        expect(defered_time.to_i).to be < now.to_i + 3
        
      end
      
    end
    
  end
  
end
