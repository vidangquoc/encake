class UserFinishLessonEvent < UserEvent
  
  def process
    
    user = User.find(user_id)
    new_notifications = []
    
    user.friends.each do |friend|
      
      existing_unprocessed_notification = NotificationFinishLesson.find_by(
                                                                            from_user_id: user.id,
                                                                            to_user_id: friend.id,
                                                                            is_processed: false,
                                                                            
                                                                          )
      if existing_unprocessed_notification.nil?
        new_notifications.push(NotificationFinishLesson.new(
                                                         from_user_id: user.id,
                                                         to_user_id: friend.id,
                                                         from_event_id: self.id,
                                                         defer_until: DateTime.now + 30.minutes,
                                                         data: {
                                                            score_change: data.fetch(:score_change),
                                                            lesson_id: [data.fetch(:lesson_id)],
                                                            score_diff: user.score - friend.score
                                                          }
                                                         
                                                        )
                              )
        
      else
        existing_unprocessed_notification.from_event_id = self.id
        existing_unprocessed_notification.data[:score_change] += data.fetch(:score_change)
        existing_unprocessed_notification.data[:lesson_id] += [data.fetch(:lesson_id)]
        existing_unprocessed_notification.data[:score_diff] = user.score - friend.score
        existing_unprocessed_notification.defer_until = DateTime.now + 30.minutes
        existing_unprocessed_notification.save
      end
      
    end
    
    NotificationFinishLesson.import new_notifications if new_notifications.any?
    
  end
  
end