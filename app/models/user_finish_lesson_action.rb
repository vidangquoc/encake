class UserFinishLessonAction < UserAction
  
  def process
    create_finish_lesson_event
    super
  end
  
  handle_asynchronously :process
  
  private
  
  def create_finish_lesson_event()
    lesson_id = data.fetch(:lesson_id)
    score_change = data.fetch(:score_change)
    UserFinishLessonEvent.create user_id: user.id, from_action_id: self.id, data: {lesson_id: lesson_id, score_change: score_change}
  end
  
end