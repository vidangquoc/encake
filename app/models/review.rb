class Review < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :point
  
  has_many :review_skills, dependent: :destroy
  
end
