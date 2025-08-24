class MailPreview < MailView
  def point_reiviewed_notify
    notification = Notification.new(from_user_id: User.first.id, to_user_id: User.second.id)
    notification.data  = {number_of_reviewed_items: 8, score_change: 5, score_diff: -1500}
    PointReviewedMailer.notify(notification)
  end
  def overcome_friend_notify
    notification = Notification.new(from_user_id: User.first.id, to_user_id: User.second.id)
    notification.data[:score_diff] = 15
    notification.data[:teaser_id] = 1
    OvercomeFriendMailer.notify(notification)
  end
  def finish_lesson_notify
    notification = Notification.new(from_user_id: User.first.id, to_user_id: User.second.id)
    notification.data = {score_added: 15, lesson_id: [1,2], score_diff:-1550}
    FinishLessonMailer.notify(notification)
  end
  def reach_new_level_notify
    notification = Notification.new(from_user_id: User.first.id, to_user_id: User.second.id)
    notification.data = {new_level_id: 2}
    ReachNewLevelMailer.notify(notification)
  end
  def confirm_registration
    user = User.first
    user.generate_password
    UserMailer.confirm_registration(user)
  end
  def recover_password
    user = User.first
    user.set_recovering_password('recovering-password')
    UserMailer.recover_password(user)
  end
  def administrator_notify()
    AdministratorMailer.notify("hi, dai ca", "This is the content")
  end
  def got_badge_notify()
    notification = Notification.new(from_user_id: User.first.id, to_user_id: User.second.id)
    notification.data = {badge_type_id: BadgeType.where(badge_type: 'warrior').first.id}
    GotBadgeMailer.notify(notification)
  end
end