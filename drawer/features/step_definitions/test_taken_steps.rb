#Given(/^I'm ready to take test/) do
#  
#  5.Levels.has_5_lessons(:assoc).each_has_10_points(:assoc).each_has_6_questions(:assoc).each_has_3_answers  
#  Question.all.each do |question|
#    question.right_answer = question.answers.sample
#    question.save
#  end
#  Level.serial_update :number => [1,2,3,4,5]
#  @user = User.one.belongs_to Level.third
#  signin @user  
#  
#end
#
#
#When(/^I access the test page$/) do
#  visit pre_test_path
#  click 'create_test_btn'
#end
#And(/^I answer "(.*?)" of the questions corectly and submit the test$/) do |percent|     
#  
#  question_ids = get_ids('question')
#  question_ids_with_right_answer = question_ids.sample( question_ids.count*(percent.to_i)/100 )
#  question_ids_with_wrong_answer = question_ids - question_ids_with_right_answer
#  
#  question_ids_with_right_answer.each do |question_id|
#    question = Question.find(question_id)
#    choose find(".answer_#{question.right_answer.id}")['id']
#  end
#  
#  question_ids_with_wrong_answer.each do |question_id|
#    question = Question.find(question_id)
#    choose find(".answer_#{question.random_wrong_answer.id}")['id']
#  end 
#  
#  click 'test_submit'
#  
#end
#Then(/^I'm advanced to the next level$/) do
#  
#  has_tag_with_id('span','test_passed_notice')
#  expect(@user.reload.level.id).to eq Level.fourth.id
#  
#end
#
#
#
#Then(/^I'm told that I has failed the test$/) do
#  
#  has_tag_with_id "span", "test_failed_notice"
#  
#end
#
#
#
#Given(/^My current level is the first level$/) do
#  
#  @user.belongs_to Level.first 
#  
#end
#Then(/^I see my test with (\d+) questions, all from current level$/) do |number_of_questions|
#  
#  question_ids_on_page = get_ids('question')
#  total_number_of_questions = question_ids_on_page.count
#  number_of_questions_from_current_level = (question_ids_on_page & @user.current_questions.map(&:id)).count
#  #assertions
#  expect(total_number_of_questions).to eq number_of_questions.to_i
#  expect(number_of_questions_from_current_level).to eq total_number_of_questions
#  
#end
#
#
#
#Given(/^My current level is the second level$/) do
#  
#  @user.belongs_to Level.second  
#  
#end
#Then(/^I see my test with (\d+) questions, (\d+)% from current level, the others from the first level$/) do |number_of_questions, percent_from_current|
#    
#  question_ids_on_page = get_ids('question')  
#  number_of_questions_from_current_level = (question_ids_on_page & @user.current_questions.map(&:id)).count   
#  number_of_questions_from_previous_levels = (question_ids_on_page & @user.previous_questions.map(&:id)).count  
#  #assertions
#  expect(question_ids_on_page.count).to eq number_of_questions.to_i
#  expect(number_of_questions_from_current_level).to eq (number_of_questions.to_i*percent_from_current.to_i/100)
#  expect(number_of_questions_from_previous_levels).to eq (number_of_questions.to_i*(100 - percent_from_current.to_i)/100)
#  
#end
#
#
#Given(/^My current level is "(.*?)"$/) do |level_number|
#  @user.belongs_to Level.where(:number => level_number).first
#end
#Then(/^I see my test with (\d+) questions, (\d+)% from current level, the others from previous levels$/) do |number_of_questions, percent_from_current|
#   
#  question_ids_on_page = get_ids('question')  
#  number_of_questions_from_current_level = (question_ids_on_page & @user.current_questions.map(&:id)).count   
#  number_of_questions_from_previous_levels = (question_ids_on_page & @user.previous_questions.map(&:id)).count  
#  #assertions
#  expect(question_ids_on_page.count).to eq number_of_questions.to_i
#  expect(number_of_questions_from_current_level).to eq (number_of_questions.to_i*percent_from_current.to_i/100)
#  expect(number_of_questions_from_previous_levels).to eq (number_of_questions.to_i*(100 - percent_from_current.to_i)/100)
#  
#end
#
#
#When(/^I submit the test$/) do
#  click 'test_submit'
#end
#Then(/^The test is marked as finished$/) do
#  expect(@user.taken_tests.last.finished).to be true
#end
