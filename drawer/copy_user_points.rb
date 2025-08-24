class UserPoint < ActiveRecord::Base
  
  def copy
    
    UserPoint.transaction do
    
      review = Review.create(
                              user_id: self.user_id,
                              point_id: self.point_id,
                              current_skill: ReviewSkill::SKILLS[:grammar],
                              is_active: true
                            )
      
      ReviewSkill::SKILLS.values.each do |skill|
        
        ReviewSkill.create(
          review_id: review.id,
          skill: skill,
          reviewed_times: self.reviewed_times,
          effectively_reviewed_times: self.effectively_reviewed_times,
          review_due_date: self.review_due_date,
          last_reviewed_date: self.last_reviewed_date
        )
        
      end
      
      destroy
    
    end
    
  end
  
end

UserPoint.all.each do |up|
  up.copy
end


