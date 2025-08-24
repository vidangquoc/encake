class ExampleAlternative < ActiveRecord::Base
  
  strip_attributes collapse_spaces: true
  
  belongs_to :example
  
  after_save :touch_example
  after_destroy :touch_example
  
  validates :example_id, {
    :presence => true
  }
  
  validates :content, {
    :presence => true
  }
  
  def mark_for_destruction=(value)    
    mark_for_destruction() if value.to_i == 1
  end
  
  private
  
  def touch_example
    example.update_attribute :updated_at, DateTime.now if example
  end
  
end
