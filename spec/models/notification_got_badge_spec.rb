require 'rails_helper'

describe NotificationGotBadge do
  
  describe 'methods' do
    
    describe 'process' do
      
      before :each do
        create_badge_types
        @badge_type = find_badge_type('warrior', 2)
        @level1, @level2 = 2.Levels
        @from_user, @to_user = 2.Users
        @notification = NotificationGotBadge.create(
                                                      from_user_id: @from_user.id,
                                                      to_user_id: @to_user.id,
                                                      data: {badge_type_id: @badge_type.id}
                                                    )
      end
      
      it "sends notification email to receiver" do
        @notification.process
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.to).to eq [@to_user.email]
        expect(last_email.html_part.body).to match(@badge_type.name)
      end
      
      it "privides push_notifications with messages" do
        
        stub_rpush_apps()
        
        3.DeviceKeys.belongs_to [@to_user]
        @notification.process
        expect(PushNotification.all.map {|notif| notif.message.blank? }.uniq).to eq [false]
      end
      
    end
    
  end
  
end