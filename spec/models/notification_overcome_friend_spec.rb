require 'spec_helper'

describe NotificationOvercomeFriend do
  
  describe 'methods' do
    
    describe 'process' do
      
      before :each do
        @from_user, @to_user = 2.Users
        @notification = NotificationOvercomeFriend.create(
                                                        from_user_id: @from_user.id,
                                                        to_user_id: @to_user.id,
                                                        data: {
                                                          score_diff: 10
                                                        }
                                                      )
      end
            
      it "sends notification email to receiver" do
        @notification.process
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.to).to eq [@to_user.email]
      end
      
      it "privides push_notifications with messages" do
        
        stub_rpush_apps()
        
        3.DeviceKeys.belongs_to [@to_user]
        @notification.data[:teaser_id] = FriendTeaser.one.id
        
        @notification.process
        expect(PushNotification.all.map {|notif| notif.message.blank? }.uniq).to eq [false]
        
      end
      
    end
    
  end
  
end