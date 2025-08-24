class GotBadgeMailer < ApplicationMailer
  def notify(notification)
    @to_user = notification.to_user
    @from_user = notification.from_user
    @badge_type = BadgeType.find_by(id: notification.data.fetch(:badge_type_id))
    mail to: @to_user.email, subject: "#{@from_user.first_name} vừa nhận được huy chương #{@badge_type.name}"
  end
end
