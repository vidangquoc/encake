class Answer < ActiveRecord::Base
  
  attr_accessor :set_as_right_answer
  strip_attributes collapse_spaces: true
    
   validates :content, {
    :presence => true    
  }    
  
  validates :question_id, {
    :presence => true    
  }
  
  belongs_to :question
  
  after_save :check_to_set_as_right_answer 
  after_destroy :tell_parent_question_to_update_validity
   
  def is_right=(value)
           
    self.set_as_right_answer = true if value
    
  end
  
  def mark_for_destruction=(value)    
    mark_for_destruction() if value.to_i == 1
  end
  
  def is_right
    question && question.right_answer_id == id
  end  
    
  private
  
  def check_to_set_as_right_answer
        
    question.update_attribute :right_answer_id, id if self.set_as_right_answer && ! question.nil?
   
  end
  
   def tell_parent_question_to_update_validity
    
    question.update_validity if question
    
  end
  
end
