class UserEvent < ActiveRecord::Base
  
  serialize :data, Hash
  
  validates :user_id, {
    :presence => true   
  }
  
  belongs_to :user
  
  has_many :notifications, foreign_key: :from_event_id
  
  after_create :process
  
  def process
    #child classes are expected to overide this method
  end
  
  def event_type
    self.class.name
  end
  
end
