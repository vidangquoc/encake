class UserReachNewLevelEvent < UserEvent
  
  def process
    
    new_notifications = []
    
    user.friends.each do |friend|
      
      new_notifications.push(NotificationReachNewLevel.new(
                                                       from_user_id: user.id,
                                                       to_user_id: friend.id,
                                                       from_event_id: self.id,
                                                       data: {
                                                          new_level_id: data.fetch(:new_level_id)
                                                        }
                                                      )
                            )
        
      
    end
    
    NotificationReachNewLevel.import new_notifications
    
  end
  
end