require 'spec_helper'

describe Notification do
  
  describe "methods" do
    
    before :each do
      2.Levels
      @from_user, @to_user = 2.Users
      @notification = Notification.create(
                                            from_user_id: @from_user.id,
                                            to_user_id: @to_user.id,
                                          )
      
      @notification2 = Notification.create(
                                            from_user_id: @from_user.id,
                                            to_user_id: @to_user.id,
                                          )
      
    end
    
    describe "process" do
      
      it "updates is_processed flag to true" do
        @notification.process
        expect(@notification.is_processed?).to be true
      end
      
      it "creates push_notifications" do
        
        stub_rpush_apps
        
        2.Levels
        @from_user, @to_user = 2.Users
        @notification = Notification.create(
                                              from_user_id: @from_user.id,
                                              to_user_id: @to_user.id,
                                            )
        
        device_keys = 3.DeviceKeys.belongs_to [@to_user]
        @notification.process
        expect(PushNotification.count).to be 1
        expect(PushNotification.first.to_device_keys.sort).to eq device_keys.map(&:key).sort
        
      end
      
    end
    
    describe "Class#process" do
      
      it "calls Class#get_notifications_to_process to get notification" do
        expect(Notification).to receive(:get_notifications_to_process).and_return(Notification.none)
        Notification.process
      end
      
      it "processes loaded notifications" do
        Notification.process
        expect(@notification.reload.is_processed?).to be true
        expect(@notification2.reload.is_processed?).to be true
      end
      
    end
    
    describe "Class#get_notifications_to_process" do
            
      it "gets un-processed notifications" do
        expect(Notification.get_notifications_to_process.map(&:id)).to eq([@notification, @notification2].map(&:id))
      end
      
      it "does not get processed notifications" do
        @notification2.update_attribute :is_processed, true
        expect(Notification.get_notifications_to_process.map(&:id)).to eq([@notification.id])
      end
      
      it "does not get notifications that are still deferred" do
        @notification2.update_attribute :defer_until, DateTime.now + 1.hour
        expect(Notification.get_notifications_to_process.map(&:id)).to eq([@notification.id])
      end
      
    end
    
  end
  
end
