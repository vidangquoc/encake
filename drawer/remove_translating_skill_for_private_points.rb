def remove_translating_skill_for_private_points(remove = false)
  
  ReviewSkill.includes(:review => :point).where(skill: ReviewSkill::SKILLS.fetch(:translating)).each do |review_skill|
    
    if(! review_skill.review.nil? &&
      ! review_skill.review.point.nil? &&
      review_skill.review.point.is_private)
      
      if remove
        review_skill.destroy
      else
        puts "found: #{review_skill.review.point.content}"
      end
      
    end
    
  end.count
  
end