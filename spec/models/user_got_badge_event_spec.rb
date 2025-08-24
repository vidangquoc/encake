require 'rails_helper'

describe UserGotBadgeEvent do
  
  describe 'methods' do
    
    describe 'process' do
      
      before :each do
        
        create_badge_types
        
        @badge_type = find_badge_type('diligent', 3)
        @user, @friend1, @friend2, @not_a_friend = 4.Users
                
        @user.has_friendships([{friend_id: @friend1.id}, {friend_id: @friend2.id}])
        
        @event = UserGotBadgeEvent.new
        @event.user_id = @user.id
        @event.data[:badge_type_id] = @badge_type.id
        
      end
      
      it 'notifies all friends about the event' do
        @event.process
        expect(NotificationGotBadge.find_by(from_user_id: @user.id, to_user_id: @friend1)).not_to be nil
        expect(NotificationGotBadge.find_by(from_user_id: @user.id, to_user_id: @friend2)).not_to be nil
      end
      
      it "does not notify non-friend users" do
        @event.process
        expect(NotificationGotBadge.find_by(to_user_id: @not_a_friend)).to be nil
      end
      
      it "provides the notifications with neccessary data" do
        @event.save #this will ca the #process method
        notification = NotificationGotBadge.find_by(from_user_id: @user.id, to_user_id: @friend1)
        expect(notification.data[:badge_type_id]).to be @badge_type.id
        expect(notification.from_event_id).to be @event.id
      end
            
    end
    
  end
  
end