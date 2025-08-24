class Syllabus < ActiveRecord::Base
  
  acts_as_list column: :syllabus_order
  
  has_many :lessons  
  has_many :questions, :through => :lessons
  has_many :taken_tests
  
  validates :name, {
    :presence => true    
  }
  
  def next
    Syllabus.where(['syllabus_order > ?', self.syllabus_order]).first
  end
  
  def first_active_lesson
    lessons.active.position_ascending.first
  end
  
end
