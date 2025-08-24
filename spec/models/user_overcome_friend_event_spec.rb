require "spec_helper"

describe UserOvercomeFriendEvent do
  
  describe "methods" do
    
    describe "process" do
      
      it "notifies the overcome friend about the change" do
        
        @user, @friend1, @friend2 = 3.Users
        event = UserOvercomeFriendEvent.create user_id: @user.id, data: {friend_id: @friend1.id, score_diff: 5}
        event.save #this will call #process method
        
        now = DateTime.now
        notification = NotificationOvercomeFriend.find_by from_user_id: @user.id, to_user_id: @friend1.id
        
        expect(notification).not_to be nil
        expect(notification.from_event_id).to be event.id
        expect(notification.defer_until.to_i).to be > (now + 5.minutes).to_i - 3
        expect(notification.defer_until.to_i).to be < (now + 5.minutes).to_i + 3
        
      end
    end
    
  end
  
end