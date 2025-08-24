class DeviceKey < ActiveRecord::Base
  
  attr_accessor :old_key
  
  PLATFORMS = ['ios', 'android']
  
  belongs_to :user
  
  validates :user_id, {
    presence: true
  }
  
  validates :key, {
    presence: true,
    uniqueness: {scope: :platform}
  }
  
  validates :platform, {
    presence: true,
    inclusion: PLATFORMS
  }
  
end

class << DeviceKey
  
  def change_key(platform, old_key, new_key)
    device_key = find_by(platform: platform, key: old_key)
    device_key.update_attribute :key, new_key if ! device_key.nil?
  end
  
  def delete_key(platform, key)
    where(platform: platform, key: key).destroy_all
  end
  
  def create_or_update_key(user_id, platform, old_key, new_key)
    
    device_key =  DeviceKey.find_by({user_id: user_id, platform: platform, key: old_key}) ||
                  DeviceKey.find_by({user_id: user_id, platform: platform, key: new_key}) ||
                  DeviceKey.new(user_id: user_id, platform: platform)
    
    device_key.key = new_key
    
    if(device_key.save)
      {saved: true, device_key: device_key}
    else
      {saved: false, device_key: device_key}
    end
    
  end
  
end