class Sound < ActiveRecord::Base 
  
  validates :for_content, {
    :presence => true,
    :uniqueness => {:case_sensitive => false}
  }
  
  has_many :points
  has_many :examples
  
  after_create :schedule_fetching_sound
  after_update :expire_sound_cache, :touch_points, :touch_examples
  
  def fetch_data
    
    mp3_data = of_a_word? ? Network::TextToSpeech.word_to_speech(for_content) : Network::TextToSpeech.phase_to_speech(for_content)       
      
    if mp3_data.instance_of?(Array)
      
      Sound.where(['for_content = ? OR for_content = ?', "#{self.for_content}@1", "#{self.for_content}@2" ]).destroy_all
      
      sound1 = Sound.create!( :for_content => "#{self.for_content}@1", :fetched => true, :mp3 => mp3_data[0] )
      sound2 = Sound.create!( :for_content => "#{self.for_content}@2", :fetched => true, :mp3 => mp3_data[1] )          
      
      Point.where(['content = ?', self.for_content]).each do |point|               
        
        point.update_attributes :sound_id => sound1.id, :sound2_id => sound2.id, :sound_verified => false
        
      end
      
      self.class.where(id: self.id).delete_all
      
    elsif ! mp3_data.blank?
           
      self.mp3 = mp3_data
      self.fetched = true
      save
      
    end
    
    self.fetched_times += 1  if ! self.destroyed?
    
  end  
  handle_asynchronously :fetch_data
  
  private
  
  def schedule_fetching_sound
    fetch_data if !self.fetched?
  end
  
  def of_a_word?
    Point.is_word?(self.for_content)
  end
  
  def of_a_phase?
    Point.is_phase?(self.for_content)
  end
  
  def expire_sound_cache
    if mp3_changed?
      
      cache_file_path = Rails.application.routes.url_helpers.url_for(
                                                    controller: 'sounds',
                                                    action: 'show',
                                                    id: self.id,
                                                    version: self.updated_at_was.to_i,
                                                    format: 'mp3',
                                                    only_path: true
        )
           
      ActionController::Base.expire_page(cache_file_path)
      
    end    
  end
  handle_asynchronously :expire_sound_cache
  
  def touch_points
    points.each {|point| point.update_attribute :updated_at, DateTime.now }
  end
  
  def touch_examples
    examples.each {|example| example.update_attribute :updated_at, DateTime.now }
  end
  
end
