class NotificationReachNewLevel < Notification
  
  private
  
  def send_email
    ReachNewLevelMailer.delay.notify(self)
  end
  
  def build_push_notification(to_platform, to_device_keys)
    
    new_level = Level.find_by(id: data.fetch(:new_level_id))
    
    message = "#{from_user.first_name} vừa lên cấp #{new_level.position}"
    
    super.merge({message: message})
    
  end
  
end