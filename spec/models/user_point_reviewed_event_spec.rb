require 'spec_helper'

describe UserPointReviewedEvent do
  
  describe 'methods' do
    
    describe 'process' do
      
      before :each do
        
        @user, @friend1, @friend2, @not_a_friend = 4.Users
                
        @user.has_friendships([{friend_id: @friend1.id}, {friend_id: @friend2.id}])
        
        @event = UserPointReviewedEvent.new
        @event.user_id = @user.id
        @event.data[:score_change] = 5
        @event.data[:number_of_reviewed_items] = 7
        
      end
      
      it 'notifies all friends about the score change' do
        @event.process
        expect(NotificationPointReviewed.find_by(from_user_id: @user.id, to_user_id: @friend1)).not_to be nil
        expect(NotificationPointReviewed.find_by(from_user_id: @user.id, to_user_id: @friend2)).not_to be nil
      end
      
      it "does not notify non-friend users" do
        @event.process
        expect(NotificationPointReviewed.find_by(from_user_id: @user.id, to_user_id: @not_a_friend)).to be nil
      end
      
      it "provides the notifications with neccessary data" do
        
        @event.save #this will call #process method
        notification = NotificationPointReviewed.find_by(from_user_id: @user.id, to_user_id: @friend1.id)
        expect(notification.data[:score_change]).to be 5
        expect(notification.data[:number_of_reviewed_items]).to be 7
        expect(notification.from_event_id).to be @event.id
        
      end
      
      it "provides score differences between the user and friends" do
        @user.update_attribute :score, 10
        @friend1.update_attribute :score, 15
        @event.process
        notification = NotificationPointReviewed.find_by(from_user_id: @user.id, to_user_id: @friend1.id)
        expect(notification.data[:score_diff]).to eq(-5)
      end
      
      it "sets half an hour for notification defer time" do
        
        @event.process
        now = DateTime.now
        defered_time = NotificationPointReviewed.find_by(from_user_id: @user.id, to_user_id: @friend1).defer_until
        
        expect(defered_time.to_i).to be > (now + 30.minutes).to_i - 3
        expect(defered_time.to_i).to be < (now + 30.minutes).to_i + 3
        
      end
      
      context "A notification of the same type with the same 'from_user_id' and 'to_user_id' exists" do
        
        before :each do
          
          @existing_notification_defer_until = DateTime.now - 5.minutes
          
          @existing_notification = NotificationPointReviewed.create({
            from_user_id: @user.id,
            to_user_id: @friend1.id,
            defer_until: @existing_notification_defer_until,
            data: {
              score_change: 6,
              score_diff: 7,
              number_of_reviewed_items: 8
            }
          })
          
        end
          
        context "The existing notification hasn't been processed" do
          
          it "does not create a new notification" do
            @event.process
            expect(NotificationPointReviewed.where(from_user_id: @user.id, to_user_id: @friend1.id).count).to eq 1
          end
          
          it "updates the existing notification" do 
            
            @event.save #this will call #process method
            @existing_notification.reload
            now = DateTime.now
            
            expect(@existing_notification.defer_until.to_i).to be > (now + 30.minutes).to_i - 3
            expect(@existing_notification.defer_until.to_i).to be < (now + 30.minutes).to_i + 3
            expect(@existing_notification.data[:score_change]).to be 11 # 6 + 5
            expect(@existing_notification.data[:number_of_reviewed_items]).to be 15 # 8 + 7
            expect(@existing_notification.from_event_id).to be @event.id
            
          end
          
          it "updates 'score_diff" do
            @friend1.update_attribute :score, 10
            @user.update_attribute :score, 20
            @event.process
            @existing_notification.reload
            expect(@existing_notification.data[:score_diff]).to eq 10 # 20 - 10
          end
          
        end
        
        context "The existing notification has been processed" do
          
          before :each do
            @existing_notification.update_attribute :is_processed, true
          end
          
          it "creates a new notification" do            
            @event.process
            expect(NotificationPointReviewed.where(from_user_id: @user.id, to_user_id: @friend1.id).count).to eq 2
          end
                    
        end
        
      end
      
    end
    
  end
  
end