class UserOvercomeFriendEvent < UserEvent
  def process
    NotificationOvercomeFriend.create(
                                      from_user_id: user_id,
                                      to_user_id: data.fetch(:friend_id),
                                      from_event_id: self.id,
                                      defer_until: 5.minutes.from_now,
                                      data:{
                                        score_diff: data.fetch(:score_diff)
                                      }
                                    )
  end
end