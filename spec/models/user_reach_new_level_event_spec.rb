require 'spec_helper'

describe UserReachNewLevelEvent do
  
  describe 'methods' do
    
    describe 'process' do
      
      before :each do
        
        @user, @friend1, @friend2, @not_a_friend = 4.Users
                
        @user.has_friendships([{friend_id: @friend1.id}, {friend_id: @friend2.id}])
        
        @event = UserReachNewLevelEvent.new
        @event.user_id = @user.id
        @event.data[:new_level_id] = 2
        
      end
      
      it 'notifies all friends about the event' do
        @event.process
        expect(NotificationReachNewLevel.find_by(from_user_id: @user.id, to_user_id: @friend1)).not_to be nil
        expect(NotificationReachNewLevel.find_by(from_user_id: @user.id, to_user_id: @friend2)).not_to be nil
      end
      
      it "does not notify non-friend users" do
        @event.process
        expect(NotificationReachNewLevel.find_by(to_user_id: @not_a_friend)).to be nil
      end
      
      it "provides the notifications with neccessary data" do
        @event.save #this will ca the #process method
        notification = NotificationReachNewLevel.find_by(from_user_id: @user.id, to_user_id: @friend1)
        expect(notification.data[:new_level_id]).to be 2
        expect(notification.from_event_id).to be @event.id
      end
            
    end
    
  end
  
end