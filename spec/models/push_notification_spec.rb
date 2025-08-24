require_relative '../spec_helper'

describe PushNotification do
  
  describe 'validations' do
    
    subject do
      stub_rpush_apps
      FactoryBot.create(:push_notification)
    end      
    
    it { is_expected.to validate_presence_of(:to_user_id) }
    
    it { is_expected.to validate_presence_of(:message) }
    
    it { is_expected.to validate_presence_of(:to_device_keys) }
    
    it { is_expected.to validate_presence_of(:platform) }
    
  end
  
  describe 'callbacks' do
    
    describe 'after create' do
      
      it 'create corresponding rpush notification' do
        
        PushNotification.create_rpush_apps
        
        push_notification = FactoryBot.build :push_notification
        push_notification.platform = 'android'
        push_notification.save!
        
        expect(Rpush::Gcm::Notification.count).to be 1
        
        
      end
      
    end
    
  end

end
