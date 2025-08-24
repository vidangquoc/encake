class PushNotification < ActiveRecord::Base
  
  serialize :to_device_keys, Array
    
  validates :to_user_id, {
    presence: true
  }
  
  validates :message, {
    presence: true
  }
  
  validates :to_device_keys, {
    presence: true
  }
  
  validates :platform, {
    presence: true
  }
  
  after_create :create_rpush_notification
  
  private
  
  def create_rpush_notification
    
    if platform == 'android'
      Rpush::Gcm::Notification.create(
        app: Rpush::Gcm::App.find_by_name("android"),
        registration_ids: self.to_device_keys,
        data: {
            title: '',
            message: self.message,
            vibrate: 1,
            sound: 1
          }
      )
    end
    
    self.update_attribute :sent, true
    
  end
  
end

class << PushNotification
  
  def create_rpush_apps
    create_rpush_app_for_android
  end
  
  private
  
  def create_rpush_app_for_android
    
    app = Rpush::Gcm::App.find_by(name: 'android') || Rpush::Gcm::App.new(name: 'android')
    app.auth_key = Constants.push_notification_key.android
    app.connections = 1
    app.save!
    app
    
  end
  
end
