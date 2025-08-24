class UserGotBadgeEvent < UserEvent
  
  def process
    
    new_notifications = []
    
    user.friends.each do |friend|
      
      new_notifications.push(NotificationGotBadge.new(
                                                       from_user_id: user.id,
                                                       to_user_id: friend.id,
                                                       from_event_id: self.id,
                                                       data: {
                                                          badge_type_id: data.fetch(:badge_type_id)
                                                        }
                                                      )
                            )
        
      
    end
    
    NotificationGotBadge.import new_notifications
    
  end
  
  handle_asynchronously :process
  
end