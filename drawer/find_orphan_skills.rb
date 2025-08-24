def find_orphan_skills
  
  skills_for_private = ReviewSkill::SKILLS_TO_BUILD[:private].map{|skill_symbol| ReviewSkill::SKILLS.fetch(skill_symbol)};
  conditions = "(points.is_private = 1 && (review_skills.skill NOT IN (#{skills_for_private.join(",")})))";
  
  skills_for_valid = ReviewSkill::SKILLS_TO_BUILD[:valid].map{|skill_symbol| ReviewSkill::SKILLS.fetch(skill_symbol)};
  conditions = conditions + " || (points.is_valid = 1 && (review_skills.skill NOT IN (#{skills_for_valid.join(",")})))";
  
  skills_for_supporting = ReviewSkill::SKILLS_TO_BUILD[:supporting].map{|skill_symbol| ReviewSkill::SKILLS.fetch(skill_symbol)};
  conditions = conditions + " || (points.is_valid = 0 && points.is_supporting = 1 && (review_skills.skill NOT IN (#{skills_for_supporting.join(",")})))";
  
  ReviewSkill.all.select("review_skills.id, review_skills.skill, points.is_private, points.is_valid, points.is_supporting").joins(:review => :point).where([conditions])
  
end