class NotificationFinishLesson < Notification
  
  private
  
  def send_email
    FinishLessonMailer.delay.notify(self)
  end
  
  def build_push_notification(to_platform, to_device_keys)
    
    score_added = data.fetch(:score_change)
    
    lesson_count = data.fetch(:lesson_id).count    
    
    message = "#{from_user.name} đã học thêm #{lesson_count} bài, đạt thêm #{score_added} điểm"
    
    super.merge({message: message})
    
  end

  
end