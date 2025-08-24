module TTS
  class Engine
    def self.word_to_speech(word) #overide for faster test
      nil
    end
    def self.phase_to_speech(phase) #overide for faster test
      nil
    end
  end
end

def choose_main_example_for_points
  Point.all.each do |point|
    main_example = point.examples.first
    main_example.update_attribute(:is_main, true)
    point.update_attribute(:main_example_id, main_example.id)
  end
end

def get_point_ids
  
  point_ids = []
    
  current_point_id = get_id 'current_point'
  
  begin   
     
    point_ids.push current_point_id    
    click "next_point"
    current_point_id = get_id 'current_point'
   
  end while ! point_ids.include?(current_point_id)
    
  point_ids
  
end