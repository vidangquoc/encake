require 'spec_helper'

describe NotificationPointReviewed do
  
  describe 'methods' do
    
    describe 'process' do
      
      before :each do
        @from_user, @to_user = 2.Users
        @notification = NotificationPointReviewed.create(
                                                        from_user_id: @from_user.id,
                                                        to_user_id: @to_user.id,
                                                        data: {
                                                          score_change: 5,
                                                          score_diff: 1000,
                                                          number_of_reviewed_items: 5
                                                        }
                                                      )
      end
      
      it "sends notification email to receiver" do
        @notification.process
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.to).to eq [@to_user.email]
        expect(last_email.html_part.body).to match('5')
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