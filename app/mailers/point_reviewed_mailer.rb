class PointReviewedMailer < ApplicationMailer
  def notify(notification)
    @to_user = notification.to_user
    @from_user = notification.from_user
    @score_change = notification.data.fetch(:score_change)
    @score_diff = notification.data.fetch(:score_diff)
    @number_of_reviewed_items = notification.data.fetch(:number_of_reviewed_items)
    mail to: @to_user.email, subject: "#{@from_user.name} đã ôn tập #{@number_of_reviewed_items} mục và đạt thêm #{@score_change} điểm"
  end
end