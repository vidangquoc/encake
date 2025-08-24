def create_pronouncing_skill
  ReviewSkill.includes(:review).where(skill: ReviewSkill::SKILLS.fetch(:spelling)).find_each do |review_skill|
    pronouncing_skill = ReviewSkill.find_by(review_id: review_skill.review_id, skill: ReviewSkill::SKILLS.fetch(:pronouncing))
    if pronouncing_skill.nil?
      pronouncing_skill = ReviewSkill.new
      pronouncing_skill.review_id           = review_skill.review_id
      pronouncing_skill.skill               = ReviewSkill::SKILLS.fetch(:pronouncing)
      pronouncing_skill.reviewed_times      = review_skill.reviewed_times
      pronouncing_skill.effectively_reviewed_times = review_skill.effectively_reviewed_times
      pronouncing_skill.reminded_times      = review_skill.reminded_times
      pronouncing_skill.review_due_date     = review_skill.review_due_date
      pronouncing_skill.last_reviewed_date  = review_skill.last_reviewed_date
      pronouncing_skill.save!
    end
  end
end

#def remove_extra_spelling_skills
#  ReviewSkill.includes(:review).where(skill: ReviewSkill::SKILLS.fetch(:spelling)).find_each do |review_skill|    
#    if ReviewSkill.where(review_id: review_skill.review_id, skill: ReviewSkill::SKILLS.fetch(:spelling)).count > 1      
#      review_skill.destroy
#    end      
#  end
#end