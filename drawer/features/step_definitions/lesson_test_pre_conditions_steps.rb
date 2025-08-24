Given(/^I have decided to take lesson test$/) do    
  @lesson, @lesson2 = 2.Lessons
  @user = User.one.belongs_to_current_lesson(@lesson).belongs_to(Level.one)
  @test = TakenTest.one.belongs_to(@user).belongs_to(@user.current_lesson) 
  signin @user
end
Given(/^I have not taken the lesson test before$/) do
  @user.taken_tests.delete_all
end
When(/^I access the lesson test page$/) do
  visit test_path
end
Then(/^I see a message telling me that if I fail the lesson test I will not be able to re-take it til tomorrow$/) do 
  expect(page).to have_css("#pre_test_notice")
  expect(page).to have_css("#retake_test_tomorrow")
end
Then(/^I have chance to proceed to the lesson test$/) do  
  expect(page).to have_css("#ready_for_test_lnk")
end
Then(/^I also have chance cancel the lesson test process$/) do
  has_link href: lesson_path(@user.current_lesson)
end


Given(/^I failed the test yesterday or sooner$/) do
  @test.update_attribute 'created_on', Constants.allowed_to_retake_test_after.days.ago.to_date
end


Given(/^I have failed the test at some time today$/) do
  @test.update_attribute 'created_on', Date.today
end
Then(/^I see a message telling me that I would not be able to re-take it til tomorrow$/) do  
  expect(page).to have_css("#test_recently_failed_notice")
end


Given(/^I has some points needed to be reviewed$/) do
  @lesson.has_3_points
  @user.add_points_of_current_lesson  
  @user.user_points.first.update_attribute :review_due_date, Date.today
end
Then(/^I see a message telling me that I cannot take the test because I has points needed to be reviewed$/) do
  expect(page).to have_css("#review_needed_notice")
end
Then(/^I have change to get to the point review page$/) do
 has_link href: points_review_path
end

