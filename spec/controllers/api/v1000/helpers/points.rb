def populate_associated_objects_for_points
    
  Point.all.to_a.each_has_3_examples.each_has_4_questions
  Point.all.to_a.make_sound{ |point, sound_attrs|
    sound_attrs[:for_content] = point.content
  }
  Point.all.to_a.make_main_example(factory: :example) do |point, example_attributes|
    example_attributes[:point_id] = point.id
    example_attributes[:is_main] = true
    example_attributes[:sound_id] = Sound.one(factory: [:sound, for_content: example_attributes[:content]]).id
  end
end

def assert_correct_point_data(json_point)
  
  point = Point.find(json_point.id)
  
  expect(json_point.sound_id).to eq point.sound_id
  expect(json_point.content).to eq point.content
  expect(json_point.split_content).to eq point.split_content
  expect(json_point.pronunciation).to eq point.pronunciation
  expect(json_point.point_type).to eq point.point_type
  expect(json_point.meaning).to eq point.meaning
  expect(json_point.meaning_in_english).to eq point.meaning_in_english
  expect(json_point.adding_user_id).to eq point.adding_user_id
  
  expect(json_point.sound).not_to be nil
  expect(json_point.sound.id).to eq point.sound.id
  expect(DateTime.parse(json_point.sound.updated_at).to_i).to eq point.sound.updated_at.to_i
  expect(json_point.sound.url).not_to be nil
  
  expect(json_point.main_example).not_to be nil
  expect(json_point.main_example.id).to eq point.main_example.id
  expect(json_point.main_example.sound_id).to eq point.main_example.sound_id
  expect(json_point.main_example.content).to eq point.main_example.content
  expect(json_point.main_example.meaning).to eq point.main_example.meaning
  
  expect(json_point.main_example.sound).not_to be nil
  expect(json_point.main_example.sound.id).to eq point.main_example.sound.id
  expect(DateTime.parse(json_point.main_example.sound.updated_at).to_i).to eq point.main_example.updated_at.to_i
  expect(json_point.main_example.sound.url).not_to be nil
    
end