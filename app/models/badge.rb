class Badge < ActiveRecord::Base
  strip_attributes collapse_spaces: true
end

class << Badge
  
  def reward_to_user(user_id, badge_type_id, number_of_badges = 1)
    
    badge = find_badge(user_id, badge_type_id)
    
    if badge.nil?
      Badge.create! user_id: user_id, badge_type_id: badge_type_id, number_of_badges: number_of_badges
    else
      badge.update_attributes number_of_badges: badge.number_of_badges + number_of_badges
    end
    
  end
  
  def reward_lucky_stars_to_user(user_id, number_of_rewarded_lucky_stars)
    reward_to_user(user_id, lucky_star_badge_type.id, number_of_rewarded_lucky_stars)
  end
  
  def count_lucky_stars_for_user(user_id)
    lucky_star_badge = find_badge(user_id, lucky_star_badge_type.id)
    ( lucky_star_badge.nil? ? 0 : lucky_star_badge.number_of_badges )
  end
  
  def take_luck_stars_from_user(user_id, number_of_lucky_stars)
    lucky_star_badge = find_badge(user_id, lucky_star_badge_type.id)
    lucky_star_badge.update_attributes number_of_badges: (lucky_star_badge.number_of_badges - number_of_lucky_stars) if lucky_star_badge
  end
  
  def toss_lucky_stars_to_user(user_id)
    is_won = Opportunity.toss(33)
    number_of_lucky_stars = 0
    if is_won
      number_of_lucky_stars = rand_number_of_lucky_stars
      reward_lucky_stars_to_user(user_id, number_of_lucky_stars)
    end
    number_of_lucky_stars
  end
  
  def rand_number_of_lucky_stars
    rand(2..7)
  end
    
  private
  
  def find_badge(user_id, badge_type_id)
    Badge.find_by(user_id: user_id, badge_type_id: badge_type_id)
  end
  
  def lucky_star_badge_type
    BadgeType.find_by(badge_type: 'lucky_star')
  end
  
end
