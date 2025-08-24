class Notification < ActiveRecord::Base
  
  strip_attributes collapse_spaces: true
  
  belongs_to :to_user, class_name: 'User', foreign_key: :to_user_id
  belongs_to :from_user, class_name: 'User', foreign_key: :from_user_id
  serialize :data, Hash
  
  def process
    update_attribute :is_processed, true
    send_email
    create_push_notifications
  end
  
  def event_type
    self.class.name
  end
  
  protected
  
  def create_push_notifications
    
    device_keys = {}
    
    to_user.device_keys.each do |device_key|
      device_keys[device_key.platform] = [] if device_keys[device_key.platform].nil?
      device_keys[device_key.platform] << device_key.key
    end
    
    device_keys.each_pair do |platform, keys|
      PushNotification.create! build_push_notification(platform, keys)
    end
    
  end
  
  def build_push_notification(platform, keys)
    #Child classes are expected to overide this method to provide the appropriate message
    {to_user_id: to_user.id, platform: platform, to_device_keys: keys, message: 'hi'}
  end
  
  def send_email
    #Child classes are expected to overide this method to send email to user
  end
    
end

class << Notification
  
  def process
    get_notifications_to_process.find_each do |notification|
      notification.process
    end
  end
  
  def get_notifications_to_process
    where(is_processed: false).where(['defer_until IS NULL OR defer_until < ?', DateTime.now ])
  end
  
end
