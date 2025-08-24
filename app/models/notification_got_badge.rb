class NotificationGotBadge < Notification
  
  private
  
  def send_email
    GotBadgeMailer.delay.notify(self)
  end
  
  def build_push_notification(to_platform, to_device_keys)
    
    badge_type = BadgeType.find_by(id: data.fetch(:badge_type_id))
    
    message = "#{from_user.first_name} vừa nhận được huy chương #{badge_type.name}"
    
    super.merge({message: message})
    
  end
  
end