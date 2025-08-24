class FinishLessonMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  def notify(notification)
    @to_user = notification.to_user
    @from_user = notification.from_user
    @score_added = notification.data.fetch(:score_change)
    @score_diff = notification.data.fetch(:score_diff)
    @lesson_count = notification.data.fetch(:lesson_id).count    
    mail to: @to_user.email, subject: "#{@from_user.name} đã học thêm #{@lesson_count} bài, đạt thêm #{@score_added} điểm"
  end
end
