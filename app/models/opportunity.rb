class Opportunity < ActiveRecord::Base
  
  belongs_to :badge_type
  belongs_to :user
  
  def ignore
    update_attributes is_taken: true
  end
  
  def take(number_of_used_lucky_stars)
    
    transaction do
    
      review_summary = ReviewSummary.find_by(user_id: self.user_id)
      if !review_summary.nil?
        if self.badge_type.badge_type == 'diligent'
          review_summary.update_attributes continuous_reviewing_days: review_summary.continuous_reviewing_days - self.badge_type.number_of_efforts_to_get
        elsif self.badge_type.badge_type == 'warrior'
          review_summary.update_attributes number_of_reviewed_items_today: review_summary.number_of_reviewed_items_today - self.badge_type.number_of_efforts_to_get
        end
      end
      
      pos = calculate_possibility(number_of_used_lucky_stars)
      win = Opportunity.toss(pos[:possibility])
      if win
        Badge.reward_to_user(self.user_id, self.badge_type.id)
        UserGotBadgeEvent.create(user_id: self.user_id, data: {badge_type_id: self.badge_type.id})
      end
      
      Badge.take_luck_stars_from_user(self.user_id, pos[:number_of_used_lucky_stars] ) if pos[:number_of_used_lucky_stars] > 0 
      
      destroy
      
      win
    
    end
    
  end
  
  def calculate_possibility(number_of_used_lucky_stars)
    
    max_usable_lucky_stars = Constants.max_opportunity_possibility - Constants.min_opportunity_possibility
    number_of_lucky_stars_user_has = Badge.count_lucky_stars_for_user(self.user.id)
    
    number_of_used_lucky_stars = number_of_lucky_stars_user_has if number_of_used_lucky_stars > number_of_lucky_stars_user_has
    number_of_used_lucky_stars = max_usable_lucky_stars if number_of_used_lucky_stars > max_usable_lucky_stars
    
    {
      possibility: Constants.min_opportunity_possibility + number_of_used_lucky_stars,
      number_of_used_lucky_stars: number_of_used_lucky_stars
    }
    
  end
  
end

class << Opportunity
  
  def toss(possibility)
    if rand(1..100) <= possibility
      return true
    else
      return false
    end
  end
  
end