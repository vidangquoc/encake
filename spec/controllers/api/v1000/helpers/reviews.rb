def prepare_review_test_data
  
  4.Levels
  2.Lessons.belongs_to(2.Syllabus).each_has_3_points
  create_badge_types
  
  populate_associated_objects_for_points
  
  @user = User.one
  @user.belongs_to Level.first
  @user.belongs_to_current_lesson Lesson.second
  
  allow_any_instance_of(PointImage).to receive(:small_url).and_return('small_url')
  allow_any_instance_of(PointImage).to receive(:medium_url).and_return('medium_url')
  allow_any_instance_of(PointImage).to receive(:big_url).and_return('big_url')
    
end

def add_points_to_bag(point_range)
  
  reviews = @user.send("has_#{point_range.count}_reviews", :assoc).belongs_to(Point.where(id: point_range).to_a)
  
  review_skills = []
  
  reviews.each do |review|
  
    skills = review.has_review_skills( ReviewSkill::SKILLS.values.map{|skill| { skill: skill } }, :assoc)
    
    review_skills.push(skills)
    
  end  
  
  review_skills
  
end

def add_all_points_to_bag
  add_points_to_bag(1..Point.count)
end

def make_all_review_skills_undue
  
  @user.review_skills.update_all({
    effectively_reviewed_times: 1,
    review_due_date: Date.today + 20.days,
    last_reviewed_date: Date.today - 2.days
  });
          
end

def make_all_review_skills_reviewed_today
  
  @user.review_skills.update_all({
    effectively_reviewed_times: 1,
    review_due_date: Date.today + 20.days,
    last_reviewed_date: Date.today
  });
          
end

def build_learning_data_for_points(point_range)

  data = []

  Point.where(id: point_range).each do |point|
    
    ReviewSkill::SKILLS.keys.each do |skill_symbol|
      data << {'point_id' => point.id, 'skill_symbol' => skill_symbol.to_s, 'reminded_times' => '1', 'is_mastered' => false}      
    end
    
  end
  
  data
  
end

def build_review_data_for_points(point_range)

  data = []

  @user.reviews.includes(:review_skills).where(point_id: point_range).each do |review|
                                                 
    review.review_skills.each do |skill|
      data <<  {'skill_id' => skill.id, 'reminded_times' => 0, 'is_mastered' => false}  
    end
    
  end
  
  data
  
end

def destroy_points_greater_than(id)
  Point.where(['id > ?', id]).destroy_all
end

def find_review_skill(point_id, skill_symbol)
  @user.review_skills.where(["reviews.point_id = ?", point_id]).where(skill: ReviewSkill::SKILLS[skill_symbol]).first
end

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
  Example.all.to_a.each_has_2_alternatives(factory: :example_alternative)
  Point.all.each do |point|
    image = PointImage.new(point_id: point.id)
    image.save!(validate: false)
  end
  
  Question.all.each do |question|
    question.send "has_#{rand(1..3)}_answers"
  end
         
  Question.all.to_a.make_right_answer(factory: :answer) do |question, answer_attributes|
    answer_attributes[:question_id] = question.id
    answer_attributes[:content] = 'Choose me!'
  end
  
end

def assert_returned_data_of_review_proccess(expected_review_response_data)
  
  raise "@forced_mode is expected to be set" if @forced_mode.nil?
  raise "@practicing_data is expected to be set" if @practicing_data.nil?
  
  post :process_review, forced_mode: @forced_mode, reminded_times: @practicing_data
  
  should respond_with 200
  
  assert_process_review_result(json_response.process_review_result)
  
  assert_returned_data_of_review expected_review_response_data
  
  point = json_response.points.first if ! json_response.points.nil?
  
  assert_returned_point_data(point) if ! point.nil?
  
end

def assert_returned_data_of_review_init(expected_review_response_data)
  
  raise "@forced_mode is expected to be set" if @forced_mode.nil?
  
  get :init_review, forced_mode: @forced_mode
          
  should respond_with 200
  
  assert_returned_data_of_review expected_review_response_data
  
  assert_returned_point_data(json_response.points.first) if !json_response.points.first.nil?
  
end

def assert_returned_around_levels_review_proccess
  
  raise "@forced_mode is expected to be set" if @forced_mode.nil?
  raise "@practicing_data is expected to be set" if @practicing_data.nil?
  
  @user.level.update_attributes highest_score: @user.score + 1
  
  post :process_review, forced_mode: @forced_mode, reminded_times: @practicing_data
    
  should respond_with 200
  
  expect(json_response.around_levels.map(&:id)).to eq Level.first(3).map(&:id)
  
end

def assert_process_review_result(result)
  expect(result.score_change).not_to be nil
  expect(result.level_changed).not_to be nil
  expect(result.overcome_friends).not_to be nil
  expect(result.action_id).not_to be nil
  expect(result.number_of_rewarded_lucky_stars).not_to be nil
  expect(result.lucky_star_image).to match(/lucky_star/)
end

def assert_returned_data_of_review(expected)
  
  response = json_response
  
  @user.reload
  
  default_expected = {
    mode: nil,
    around_levels: nil,
    score: @user.score,
    due_points: @user.number_of_due_points,
    learnt_points: nil,
    points_count: 0,
  }
  
  expected = default_expected.merge(expected)
  
  if(expected[:around_levels].nil?)
    expect(response.around_levels).to eq nil
  else
    expect(response.around_levels.map(&:id)).to eq expected[:around_levels]
  end
  
  expect(response.mode).to eq expected[:mode]
  expect(response.score).to eq expected[:score]
  expect(response.due_points).to eq expected[:due_points]
  expect(response.learnt_points).to eq expected[:learnt_points]
  expect(response.points.count).to eq expected[:points_count]
  
end

def assert_returned_point_data(json_point)
    
  point = Point.find(json_point.id)
  
  expect(json_point.reviewed_skill).not_to be nil
  expect(json_point.skill_id).not_to be nil
  expect(json_point.effectively_reviewed_times).not_to be nil
  
  expect(json_point.sound_id).to be point.sound_id
  expect(json_point.lesson_id).to be point.lesson_id
  expect(json_point.content).to eq point.content
  expect(json_point.split_content).to eq point.split_content
  expect(json_point.pronunciation).to eq point.pronunciation
  expect(json_point.google_search_key).to eq point.google_search_key
  expect(json_point.point_type).to eq point.point_type
  expect(json_point.meaning).to eq point.meaning
  expect(json_point.is_valid).to be point.is_valid
  expect(json_point.is_private).to be point.is_private
  
  expect(json_point.sound).not_to be nil
  expect(json_point.sound.id).to eq point.sound.id
  expect(DateTime.parse(json_point.sound.updated_at)).to eq point.sound.updated_at
  expect(json_point.sound.url).to eq "/sounds/#{json_point.sound.id}/#{point.sound.updated_at.to_i}.mp3"
  
  expect(json_point.main_example).not_to be nil
  expect(json_point.main_example.id).to be point.main_example.id
  expect(json_point.main_example.sound_id).to be point.main_example.sound_id
  expect(json_point.main_example.content).to eq point.main_example.content
  expect(json_point.main_example.meaning).to eq point.main_example.meaning
  
  expect(json_point.main_example.sound).not_to be nil
  expect(json_point.main_example.sound.id).to be point.main_example.sound.id
  expect(DateTime.parse(json_point.main_example.sound.updated_at)).to eq point.main_example.sound.updated_at
  
  expect(json_point.main_example.alternatives).not_to be nil
  expect(json_point.main_example.alternatives.count).to be > 0
  expect(json_point.main_example.alternatives.first.content).to eq point.main_example.alternatives.first.content
  
  expect(json_point.question).not_to be nil
  expect(json_point.question.id).to be point.first_valid_question.id
  expect(json_point.question.question_type).to eq point.first_valid_question.question_type
  expect(json_point.question.content).to eq point.first_valid_question.content
  expect(json_point.question.answer).to eq point.first_valid_question.answer
  expect(json_point.question.right_answer_id).to be point.first_valid_question.right_answer_id
  expect(json_point.question.answers).not_to be nil
  expect(json_point.question.answers.count).to be > 0
  expect(json_point.question.answers.first.id).to be point.first_valid_question.answers.first.id
  expect(json_point.question.answers.first.content).to eq point.first_valid_question.answers.first.content
  
  expect(json_point.images.class).to be Array
  image = json_point.images.first
  expect(image.small_url).to eq 'small_url'
  expect(image.medium_url).to eq 'medium_url'
  expect(image.big_url).to eq 'big_url'
  
end

def assert_returned_opportunity(json_response, badge_type, next_badge_type)
  
  opportunity = json_response.process_review_result.opportunity
  expect(opportunity).not_to be nil
  expect(opportunity.id).not_to be nil
  expect(opportunity.badge_type.id).to eq badge_type.id
  expect(opportunity.is_taken).to be false
  
  expect(opportunity.badge_type.id).to be badge_type.id
  expect(opportunity.badge_type.name).to eq badge_type.name
  expect(opportunity.badge_type.number_of_efforts_to_get).to eq badge_type.number_of_efforts_to_get
  expect(opportunity.badge_type.image_url).to eq badge_type.image.url
  expect(opportunity.min_opportunity_possibility).to eq Constants.min_opportunity_possibility
  expect(opportunity.max_opportunity_possibility).to eq Constants.max_opportunity_possibility
  expect(opportunity.processing_image).to match(/opportunity_processing/) 
  expect(opportunity.number_of_lucky_stars).to be Badge.count_lucky_stars_for_user(@user.id)

  if( !next_badge_type.nil? )
    expect(opportunity.next_badge_type.id).to be next_badge_type.id
    expect(opportunity.next_badge_type.name).to eq next_badge_type.name
    expect(opportunity.next_badge_type.number_of_efforts_to_get).to eq next_badge_type.number_of_efforts_to_get
  else
    expect(opportunity.next_badge_type).to be nil
  end
  

end
