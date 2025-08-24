def update_private_skills(update = false)
  skills = []
  ReviewSkill.joins(:review => :point).where(skill: ReviewSkill::SKILLS.fetch(:pronounce)).where(["points.is_private = ?", true]).each do |skill|
    if ! ReviewSkill.where(review_id: skill.review.id, skill: ReviewSkill::SKILLS.fetch(:verbal) ).any?
      dictate_skill = ReviewSkill.new(
        review_id: skill.review.id,
        skill: ReviewSkill::SKILLS.fetch(:verbal),
        reviewed_times: skill.reviewed_times,
        effectively_reviewed_times: skill.effectively_reviewed_times,
        reminded_times: skill.reminded_times,
        review_due_date: skill.review_due_date,
        last_reviewed_date: skill.last_reviewed_date
      )
      skills.push(dictate_skill)
    end
  end
  if(update)
    skills.each{|skill| skill.save! }.count
  else  
    puts skills.count
  end
end
  
ReviewSkill.joins(:review => :point).where(skill: ReviewSkill::SKILLS.fetch(:verbal)).where(["points.is_private = ?", true]).order('review_skills.review_due_date ASC').limit(10).each do |skill|
  puts skill.review_due_date
end.count