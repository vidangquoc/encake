class RightAnswerExplanation < ActiveRecord::Base
  
  strip_attributes collapse_spaces: true
  
  belongs_to :lesson
  
  validates :lesson_id, presence: true
  validates :explanation, presence: true
  
end
