class ReviewSkill < ActiveRecord::Base
   
  SPACING_FACTORS = {
    interpret:    2.5,
    grammar:      3.5,
    verbal:       2.5,
  }
  
  SKILLS = {
    interpret: 0,
    grammar: 10,
    verbal: 20,
  }

  SKILLS_TO_BUILD = {
    private:    [:interpret, :verbal],
    supporting: [:interpret],
    valid:      [:interpret, :grammar, :verbal]
  }
  
  scope :due, ->{where ['review_due_date <= ?', Date.today]}
  
  scope :undue, ->{where ['review_due_date > ?', Date.today]}
  
  belongs_to :review, autosave: true
  
  def process_review(reminded_times, is_mastered = false, first_learnt_without_reminding = false)    
    effectively_reviewed_times_change = update_effectively_reviewed_times(reminded_times, is_mastered, first_learnt_without_reminding)
    update_review_due_date
    randomize_review_due_date
    increase_reviewed_times
    update_last_reviewed_date
    update_reminded_times(reminded_times)
    return effectively_reviewed_times_change
  end
  
  def update_effectively_reviewed_times(reminded_times, is_mastered = false, first_learnt_without_reminding = false)
    
    old_effectively_reviewed_times = self.effectively_reviewed_times
    
    if is_mastered
      
      self.effectively_reviewed_times = 10
      
    elsif first_learnt_without_reminding
      
      self.effectively_reviewed_times = 3
      
    elsif last_reviewed_date.nil? || last_reviewed_date < Date.today
      
      if (reminded_times == 0)
        
        self.effectively_reviewed_times += 1
        
      elsif (reminded_times == 1)
        
        self.effectively_reviewed_times = 1 if self.effectively_reviewed_times == 0
        self.effectively_reviewed_times = 2 if self.effectively_reviewed_times > 2
        
      elsif (reminded_times >= 2)
          
        self.effectively_reviewed_times = 1
        
      end
      
    end
    
    old_score = calculate_score(old_effectively_reviewed_times)
    new_score = calculate_score(self.effectively_reviewed_times)
    
    score_change = new_score - old_score
    
    score_change
        
  end  
  
  def update_review_due_date()
    
    due_in_days = self.effectively_reviewed_times == 1 ? 5 : (spacing_factor**(effectively_reviewed_times)).to_i
        
    due_date = today + due_in_days.days
    
    one_thousand_years_from_now = DateTime.now.to_date + 1000.years
    
    if due_date > one_thousand_years_from_now || ( SKILLS[:interpret] == self.skill && effectively_reviewed_times >= 3 )
      due_date = one_thousand_years_from_now
    end
    
    self.review_due_date = due_date
    
  end
  
  def randomize_review_due_date
    tomorrow = DateTime.now.to_date.tomorrow
    self.review_due_date += [-1, 0, 1].sample.days
    self.review_due_date = tomorrow if self.review_due_date < tomorrow
  end
  
  def increase_reviewed_times()
    self.reviewed_times += 1    
  end
  
  def update_last_reviewed_date()
    self.last_reviewed_date = Date.today    
  end   
  
  def update_reminded_times(reminded_times)
    self.reminded_times += reminded_times
  end
  
  private
  
  def calculate_score(effectively_reviewed_times)
    effectively_reviewed_times <= 10 ? effectively_reviewed_times : 10
  end
  
  def today
    DateTime.now.to_date
  end
  
  def skill_symbol
    ReviewSkill::SKILLS.find{|key, value| value == self.skill}.first
  end
  
  def spacing_factor
    skill_symbol = ReviewSkill::SKILLS.find{|key, value| value == self.skill}.first
    ReviewSkill::SPACING_FACTORS.fetch(skill_symbol)
  end
  
end

class << ReviewSkill
  
  def build_skills_for_review(review, mastered_skills = [], no_reminded_skills = [])
    
    skills_to_build = get_skill_to_built(review.point)
    
    skills_to_build.map do |skill|
      is_mastered = mastered_skills.any?{|sk| sk == skill}
      no_reminded = no_reminded_skills.any?{|sk| sk == skill}
      build_skill(review.id, ReviewSkill::SKILLS.fetch(skill), is_mastered, no_reminded)
    end
    
  end
  
  #def first_built_grammar_skills_for_point(point)
  #  
  #  skill_symbol = (get_skill_to_built(point) - [:spelling, :pronouncing]).first
  #  
  #  ReviewSkill::SKILLS[skill_symbol]
  #  
  #end
  
  private
  
  def get_skill_to_built(point)
    if point.is_private
      ReviewSkill::SKILLS_TO_BUILD[:private]
    elsif point.is_valid
      ReviewSkill::SKILLS_TO_BUILD[:valid]
    elsif point.is_supporting
      ReviewSkill::SKILLS_TO_BUILD[:supporting]
    else
      Log.debug "Un-specified point type"
      Log.debug point
      ReviewSkill::SKILLS_TO_BUILD[:supporting]
    end
  end
  
  def build_skill(review_id, skill, is_mastered = false, no_reminded = false)
    
    review_skill = ReviewSkill.new review_id: review_id, skill: skill
    
    review_skill.process_review(0, is_mastered, no_reminded)
        
    review_skill
    
  end
  
end
