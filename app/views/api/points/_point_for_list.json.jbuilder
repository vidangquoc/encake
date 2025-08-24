json.cache! ['point_for_list', point] do

  json.id point.id
  json.sound_id point.sound_id
  json.content point.content
  json.split_content point.split_content
  json.pronunciation point.pronunciation
  json.point_type point.point_type
  json.meaning point.meaning
  json.meaning_in_english point.meaning_in_english
  json.is_in_bag point.is_in_bag == 0 ? false : true rescue false
  json.adding_user_id point.adding_user_id

  if point.sound
    json.sound do
      json.id point.sound.id
      json.updated_at point.sound.updated_at
      if point.sound.mp3
        json.url "/sounds/#{point.sound.id}/#{point.sound.updated_at.to_i}.mp3"
      else
        json.url nil
      end
    end
  end

  if point.main_example

    json.main_example do
    
      json.id point.main_example.id
      json.sound_id point.main_example.sound_id
      json.content point.main_example.content
      json.meaning point.main_example.meaning
      
      json.sound do
      
        if  point.main_example.sound
          json.id point.main_example.sound.id
          json.updated_at point.main_example.sound.updated_at
          if point.main_example.sound.mp3
            json.url "/sounds/#{point.main_example.sound.id}/#{point.main_example.sound.updated_at.to_i}.mp3"
          else
            json.url nil
          end
        end
        
      end
          
    end
    
  end

end