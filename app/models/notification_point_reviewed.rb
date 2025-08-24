class NotificationPointReviewed < Notification
  
  private
  
  def send_email
    PointReviewedMailer.delay.notify(self)
  end
  
  def build_push_notification(to_platform, to_device_keys)
    
    score_change = data.fetch(:score_change)
    
    number_of_reviewed_items = data.fetch(:number_of_reviewed_items)
    
    message = "#{from_user.name} đã ôn tập #{number_of_reviewed_items} mục và đạt thêm #{score_change} điểm"
    
    super.merge({message: message})
    
  end
  
end