class ReviewSummary < ActiveRecord::Base
  
  strip_attributes collapse_spaces: true
  
  belongs_to :user
  
  def detect_opportunities
    
    opportunity = detect_badge_opportunity('diligent')
    
    if opportunity.nil?
      
      opportunity = detect_badge_opportunity('warrior')
      
    end
    
    opportunity
    
  end
  
  def clear_obsolete_opportunities(type)
    
    if type == 'diligent' && self.date <= DateTime.now.to_date - 2.days
      Opportunity.joins(:badge_type).where(user_id: self.user_id).where(["badge_types.badge_type = ?", 'diligent']).destroy_all
      self.update_attributes continuous_reviewing_days: 0
    end
    #
    if type == 'warrior' && self.date <= DateTime.now.to_date - 1.days
      Opportunity.joins(:badge_type).where(user_id: self.user_id).where(["badge_types.badge_type = ?", 'warrior']).destroy_all
      self.update_attributes number_of_reviewed_items_today: 0
    end
    
  end
  
  private
  
  def detect_badge_opportunity(type)
    
    number_of_efforts = (type == 'diligent' ? self.continuous_reviewing_days : self.number_of_reviewed_items_today) 
    
    badge_type = BadgeType.where(badge_type: type).where(['number_of_efforts_to_get <= ?', number_of_efforts]).order('number_of_efforts_to_get ASC').last
    
    opportunity = nil
    
    if !badge_type.nil?
      
      if ! Opportunity.where(user_id: self.user_id, badge_type_id: badge_type.id).any?
        
        opportunity = Opportunity.create! user_id: self.user_id, badge_type_id: badge_type.id, is_taken: false
        
      end
      
      Opportunity.joins(:badge_type)
      .where(user_id: self.user_id)
      .where(["badge_types.badge_type = ?", badge_type.badge_type])
      .where(["badge_type_id <> ?", badge_type.id])
      .destroy_all
      
    end
    
    opportunity
    
  end
  
end

class << ReviewSummary
  
  def update_review_summary_for_user(user_id, number_of_reviewed_items)
    
    opportunity = nil
    summary = ReviewSummary.find_by(user_id: user_id)
    
    if summary.nil?
      ReviewSummary.create user_id: user_id, date: DateTime.now.to_date, continuous_reviewing_days: 1, number_of_reviewed_items_today: number_of_reviewed_items
    else
      
      summary.clear_obsolete_opportunities('diligent')
      summary.clear_obsolete_opportunities('warrior')
      
      if summary.date <= DateTime.now.to_date - 2.days
        summary.continuous_reviewing_days = 1
        summary.number_of_reviewed_items_today = number_of_reviewed_items
      elsif summary.date == DateTime.now.to_date - 1.days
        summary.continuous_reviewing_days += 1
        summary.number_of_reviewed_items_today = number_of_reviewed_items
      else
        summary.number_of_reviewed_items_today += number_of_reviewed_items
      end
      
      summary.date = DateTime.now.to_date
      summary.save
      
      opportunity = summary.detect_opportunities
      
    end
    
    if opportunity.nil?
      opportunity = Opportunity.find_by(user_id: user_id, is_taken: false)
    end
    
    opportunity
    
  end
  
end