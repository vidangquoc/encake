class ReachNewLevelMailer < ApplicationMailer
  def notify(notification)
    @to_user = notification.to_user
    @from_user = notification.from_user
    @new_level = Level.find_by(id: notification.data.fetch(:new_level_id))
    mail to: @to_user.email, subject: "#{@from_user.first_name} vừa lên cấp"
  end
end
