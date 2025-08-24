json.reviewed_skill "#{point.reviewed_skill rescue nil}"
json.skill_id "#{point.skill_id rescue 0}"
json.effectively_reviewed_times "#{point.effectively_reviewed_times rescue 0}"

json.cache! point do

  json.extract! point, :id, :sound_id, :lesson_id, :content, :split_content, :pronunciation, :google_search_key, :point_type, :meaning, :is_valid, :is_private, :images
  json.images point.images do |image|
    json.extract! image, :id, :small_url, :medium_url, :big_url
  end
  
  if point.sound
    json.sound do
      json.extract! point.sound, :id, :updated_at
      if point.sound.mp3
        json.url "/sounds/#{point.sound.id}/#{point.sound.updated_at.to_i}.mp3"
      else
        json.url nil
      end
    end
  end
  
  if point.main_example
    json.main_example do
      json.extract! point.main_example, :id, :sound_id, :content, :meaning
      json.sound do
        if  point.main_example.sound
          json.extract! point.main_example.sound, :id, :updated_at
          if point.main_example.sound.mp3
            json.url "/sounds/#{point.main_example.sound.id}/#{point.main_example.sound.updated_at.to_i}.mp3"
          else
            json.url nil
          end
        end
      end
      json.alternatives point.main_example.alternatives.to_a do |alternative|
        json.content alternative.content
      end
    end
  end
  
  if point.first_valid_question
    json.question do
      json.extract! point.first_valid_question, :id, :question_type, :content, :answer, :right_answer_id
      json.answers point.first_valid_question.answers do |answer|
        json.extract! answer, :id, :content
      end
    end
  end

end