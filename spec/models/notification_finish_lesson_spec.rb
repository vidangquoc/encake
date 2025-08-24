require 'spec_helper'

describe NotificationFinishLesson do
  
  describe 'methods' do
    
    describe 'process' do
      
      before :each do
        @from_user, @to_user = 2.Users
        @notification = NotificationFinishLesson.create(
                                                        from_user_id: @from_user.id,
                                                        to_user_id: @to_user.id,
                                                        data: {
                                                          lesson_id: [1,2],
                                                          score_change: 25,
                                                          score_diff: 1700
                                                        }
                                                      )
      end
      
      it "sends notification email to receiver" do
        @notification.process
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.to).to eq [@to_user.email]
        expect(last_email.html_part.body).to match('25')
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