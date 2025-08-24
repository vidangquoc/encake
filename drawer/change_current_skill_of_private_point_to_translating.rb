updated_items = 0
Review.includes(:point).all.each do |review|
  if review.point.is_private && review.current_skill.nil?
    puts "Updating for review ##{review.id}"
    updated_items += 1
    review.update_attributes current_skill: ReviewSkill::SKILLS.fetch(:translating)  
  end
end.count

puts "#{updated_items} UPDATED!"
