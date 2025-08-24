Given(/^I am ready to take lesson test$/) do
  
  6.Lessons.belongs_to(3.Levels).each_has_10_points(:assoc).each_has_2_questions(:assoc).each_has_2_answers
  
  Point.a.make_main_example(factory: :example)
  
  Question.a.make_right_answer(factory: :answer)
   
  Question.all.each do |question|
    question.right_answer = question.answers.sample
    question.save
  end
  Level.serial_update :number => [1,2,3]
  
  @user = User.one.belongs_to(Level.second)
  @lesson = @user.level.lessons.first
  @user.belongs_to_current_lesson @lesson
  
  (1..4).each do |level|
    FactoryGirl.create :compliment, from: 'system', for_task: 'take_test', for_gender: @user.gender, for_correctness_level: level
  end
    
  signin @user  
  
end

Given(/^My current lesson has "(.*?)" points$/) do |number_of_points|
  
  @user.current_lesson.points.destroy_all
  @user.current_lesson.send("has_#{number_of_points}_points")  
  @user.current_lesson.points(true).to_a.each_has_2_questions(:assoc).each_has_2_answers
    
  @user.current_lesson.questions.each do |question|
    question.right_answer = question.answers.sample
    question.save
  end
  
end

When(/^I access the lesson test screen$/) do  
  visit test_path
  load_test_screen
end

Then(/^I see "(.*?)" questions presented$/) do |number_of_questions|
  expect(get_ids('question').count).to be number_of_questions.to_i
end

Then(/^All questions are chosen randomly from my current lesson$/) do
  question_ids = get_ids('question')
  expect(( question_ids & @user.current_lesson.questions.map(&:id) ).count).to be question_ids.count
  expect(question_ids.sort).not_to eq @user.current_lesson.questions.map(&:id).sort.first(question_ids.count)
end


When(/^I answer "(.*?)" of the questions in the lesson test corectly$/) do |percent|  
  answer_questions_correctly(percent.to_i)  
end
When(/^I submit the lesson test$/) do
  submit_test
end
Then(/^My current lesson is updated to the next active lesson$/) do
  expect(@user.reload.current_lesson.id).to eq @lesson.next_active.id
end


Then(/^I fail the lesson test$/) do
  expect(@user.taken_tests.last.passed?).to be false
end


Given(/^My curren lesson is the last lesson of my current level$/) do
  @lesson.move_to_bottom
end
When(/^I pass my current lesson test$/) do
  visit test_path
  load_test_screen
  answer_questions_correctly(100)
  submit_test
end
Then(/^My level is updated to the next level$/) do
  expect(@user.reload.level.id).to be Level.third.id
end


Given(/^My curren lesson is the last lesson of the last level$/) do
  @lesson = Level.last.lessons.last
  @lesson.move_to_bottom  
  @user.belongs_to_current_lesson @lesson
end
Then(/^My current lesson remains intact$/) do
  expect(@user.current_lesson.id).to be @lesson.id
end


Then(/^All points of the lesson are added to my point bags for reviewing later$/) do    
  expect(( @lesson.points.map(&:id) & @user.user_points.map(&:point_id) ).count).to eq @lesson.points.size
end
Then(/^All added points are considered to be learnt$/) do
  
  @user.user_points.each do |user_point|
          
    expect(user_point.effectively_reviewed_times).to be 1
    expect(user_point.review_due_date).to eq Date.today + 4
    expect(user_point.reviewed_times).to be 1
    expect(user_point.last_reviewed_date).to eq Date.today
    expect(user_point.reminded_times).to be 0
    
  end
  
end


When(/^I answer (\d+) percent of the questions in the lesson test corectly$/) do |number|
  answer_questions_correctly(number.to_i, true)
end


Given(/^No questions are available for the lesson$/) do
  Question.delete_all
end
Then(/^I see a message notifying me that no test are availabe for the lesson$/) do
  expect(page).to have_css('#no_question_notification')
end


Given(/^I have just finised a test$/) do
  visit test_path
  load_test_screen
  submit_test
end
Then(/^I see a compliment from my beloved$/) do
  expect(page).to have_css('#compliment')
end

Given(/^My current lesson has some invalid points$/) do
  @invalid_points = @lesson.points.sample(3)
  @invalid_points.each {|invalid_point|  invalid_point.update_attribute :is_valid, false }
end
Then(/^Invalid points are not added to my point bag$/) do
  expect(@user.user_points.map(&:point_id) & @invalid_points.map(&:id)).to eq []
end

def load_test_screen
  find('#ready_for_test_lnk').click
  find('#test_submit') #wait for the test screen to be loaded
end

def submit_test
  find('#test_submit').click
  find('#test_submit').click
  find('#compliment') #wait for the submitted data to be completely 
end

def answer_questions_correctly(percent, leave_the_rest_unanswered = false)
  
  page.execute_script("$('.question').show()")#show questions to select
  
  question_ids = get_ids('question')
  question_ids_with_right_answer = question_ids.sample( question_ids.count*(percent)/100 )
  question_ids_with_wrong_answer = question_ids - question_ids_with_right_answer
  
  question_ids_with_right_answer.each do |question_id|
    question = Question.find(question_id)
    choose_element find(".answer_#{question.right_answer.id}")
  end
  
  if !leave_the_rest_unanswered
    
    question_ids_with_wrong_answer.each do |question_id|
      question = Question.find(question_id)
      choose_element find(".answer_#{question.random_wrong_answer.id}")
    end
    
  end
    
end

def choose_element(element)
  scroll_to_element(element)
  choose element['id']
end

