class Question < ActiveRecord::Base 
  
  strip_attributes collapse_spaces: true
  
  TYPES =  {
    choosing: "Choosing",
    filling_in: "Filling In",
    filling_in_right_form: "Filling In Right Form"
  }
  
  validates :content, {
    :presence => true    
  }
   
  validates :point_id, {
    :presence => true    
  }
  
  validates :question_type, {
    :presence => true,
    :inclusion => {:in => TYPES.keys.map(&:to_s)}
  }
  
  validates :answer, {
    :presence => true, if: ->{ question_type == 'filling_in' || question_type == 'filling_in_right_form'}
  }
  
  validate :validate_content
  
  belongs_to :point
  has_many :answers, dependent: :destroy
  belongs_to :right_answer, :class_name=>'Answer', :foreign_key=>'right_answer_id'
  belongs_to :right_answer_explanation
  belongs_to :grammar_point
  
  accepts_nested_attributes_for :answers
  
  after_create :update_validity
  after_update :check_validity
  after_destroy :tell_parent_point_to_update_validity, :touch_point
  after_save :touch_point
    
  def random_wrong_answer
    answers.select {|answer| answer.id != right_answer_id }.sample
  end
  
  def update_validity
    
    if (question_type == 'choosing' && right_answer) || question_type == 'filling_in' || question_type == 'filling_in_right_form'
      
      update_column :is_valid, true #skip callbacks
      
    else
      
      update_column :is_valid, false #skip callbacks
      
    end
    
    point.update_validity if point
    
  end
  
  def explain_right_answer
    right_answer_explanation.nil? ? right_answer_explanation_parts : compose_right_answer_explanation
  end
  
  private
  
  def compose_right_answer_explanation
    explanation = right_answer_explanation.explanation.dup
    right_answer_explanation_parts.split(';').each_with_index do |part, index|
      explanation.sub!("{#{index + 1}}", part.strip)
    end
    explanation
  end
    
  def tell_parent_point_to_update_validity
    
    point.update_validity if point
    
  end
  
  def check_validity
    
    update_validity if right_answer_id_changed? or question_type_changed?
  
  end

  def validate_content
    if question_type == 'filling_in' || question_type == 'filling_in_right_form'
      if self.content !~ /\{\.\.\.\}/
        errors.add(:content, 'Không tìm thấy chuỗi {...} trong nội dung câu hỏi')
      end
    end
  end
  
  def touch_point
    point.update_attribute :updated_at, DateTime.now if point
  end
  
end

class << Question
  
  def for_lesson_test(lesson)          
    
    points = Point.select("id").includes(:questions).where(["lesson_id = ?", lesson.id])
       
    question_ids = points.map do |point|
      valid_question = point.questions.select{|question| question.is_valid }.first
      valid_question.nil? ? nil : valid_question.id
    end
       
    query = where(['questions.id IN (?)', question_ids.compact]).joins(:point).order("points.position ASC")
    
    query
    
  end
  
end