class UserReviewPointAction < UserAction
  
  def process
    create_point_reviewed_event
    super
  end
  
  handle_asynchronously :process
  
  private
  
  def create_point_reviewed_event
    score_change = data.fetch(:score_change)
    number_of_reviewed_items = data.fetch(:number_of_reviewed_items)
    UserPointReviewedEvent.create(
                                  user_id: user.id,
                                  from_action_id: self.id,
                                  data: {
                                    score_change: score_change,
                                    number_of_reviewed_items: number_of_reviewed_items
                                  }
                                )
  end
  
end