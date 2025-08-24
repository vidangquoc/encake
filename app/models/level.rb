class Level < ActiveRecord::Base
  
  acts_as_list
  
  strip_attributes collapse_spaces: true
  
  validates :highest_score, {
    :presence => true,
    :numericality =>  { :only_integer => true, :greater_than => 0},  
  }
  
  def around_levels   
    [previous_level, self, next_level]
  end
  
  private
  
  def previous_level
    Level.where('highest_score < ?', highest_score).order('highest_score DESC').first
  end
  
  def next_level
    Level.where('highest_score > ?', highest_score).order('highest_score ASC').first
  end
  
end

class << Level
  
  def get_level_for_score(score)
    where(['highest_score >= ?', score]).order('highest_score ASC').first || order('highest_score ASC').last
  end
  
end