class UserUiAction < ActiveRecord::Base
  
  validates :action, {
    :presence => true
  }
  
  validates :action_time, {
    :presence => true
  }
  
  validates :view, {
    :presence => true
  }
  
  validates :device, {
    :presence => true
  }
  
  belongs_to :user
  
end
