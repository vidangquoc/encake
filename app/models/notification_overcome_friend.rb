class NotificationOvercomeFriend < Notification
  
  private
  
  def send_email
    OvercomeFriendMailer.delay.notify(self)
  end
  
  def build_push_notification(to_platform, to_device_keys)
    
    teaser = FriendTeaser.find_by id: data[:teaser_id]
    
    message = "Cấp báo!  #{from_user.first_name} đã vượt qua bạn"
    
    message += " và '#{teaser.teasing_phase}' bạn" if !teaser.nil?
    
    super.merge({message: message})
    
  end
  
end