class Example < ActiveRecord::Base
  
  attr_accessor :set_as_main_example
  strip_attributes collapse_spaces: true
  
  belongs_to :point
  belongs_to :sound
  belongs_to :grammar_point
  has_many :alternatives, class_name: 'ExampleAlternative'
  has_many :example_point_links
  has_many :linked_points, through: :example_point_links, source: :point, class_name: 'Point'
  
  accepts_nested_attributes_for :alternatives
  
  validates :content, {
    :presence => true
  }
   
  validates :meaning, {
    :presence => true    
  }
  
  validates :point_id, {
    :presence => true
  }
  
  after_create :check_if_first_example
  after_update :check_if_content_changed
  after_save :check_to_set_as_main_example, :touch_point
  after_destroy :tell_parent_point_to_update_validity, :touch_point
  
  def is_main
    point && point.main_example_id == id
  end
  
  def is_main=(value)
    
    self.set_as_main_example = true if value   
  
  end

  def find_sound

    if self.skip_finding_sound
      return
    end

    sound = Sound.find_by_for_content(stripped_content)
    
    if sound.nil? 
      
      if self.point && !self.point.is_private
        new_sound = Sound.create(:for_content => stripped_content)
        self.update_column('sound_id', new_sound.id)
      end
      
    else           
      
      self.update_column('sound_id', sound.id) #skip callbacks
      
    end
    
  end
  
  private
  
  def stripped_content
    self.content.gsub(/\s+/,' ').strip.chomp(".")
  end
  
  def check_to_set_as_main_example
    
    if self.set_as_main_example && !point.nil?
      point.update_attribute :main_example_id, self.id
      find_sound
    end
    
  end
   
  def check_if_content_changed
    
    if content_changed? 
      
      if is_main
        
        find_sound
              
      end
            
    end      
        
  end
    
  def check_if_first_example
    if point and point.examples.count == 1
      point.update_attribute :main_example_id, self.id
      find_sound
    end
    
  end
  
  def tell_parent_point_to_update_validity
    
    point.update_validity if point
    
  end
  
  def touch_point
    point.update_attribute :updated_at, DateTime.now if point
  end
    
end
