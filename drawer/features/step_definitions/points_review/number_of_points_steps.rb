Given(/^I have no points in my point bag$/) do  
  @user.user_points.destroy_all
end
When(/^I visit point review page$/) do
  signin @user 
  visit points_review_path
end
Then(/^I am notified that I should take a test first to have points in my point bag$/) do
  expect(page).to have_css("#empty_point_list_notice")
end
Then(/^I see a link to the page for taking test$/) do
  has_link href: test_path
end

Given(/^I have "(.*?)" in my point bag$/) do |number_of_points|
  number = number_of_points.to_i
  @user.send("has_#{number}_user_points", :assoc).belongs_to(number.Points, :assoc).each_has_3_examples.belongs_to( number.Sounds(:factory) )
end
Then(/^"(.*?)" is shown to me$/) do |the_number_of_points|   
  expect(find("#total_points")).to have_text(/#{the_number_of_points}/)
end

Given(/^I have "(.*?)" in my bag of points$/) do |number_due_points|
  @user.has_40_user_points(:assoc).belongs_to(40.Points, :assoc).each_has_3_examples.belongs_to( 40.Sounds(:factory) )
  @user.user_points.first(number_due_points.to_i).each { |p| p.update_attribute(:review_due_date, Date.today - rand(3).days ) }
end
Then(/^I see "(.*?)" shown to me$/) do |number_due_points|
  expect(find("#due_points")).to have_text(/#{number_due_points}/)
end


When(/^I get "(.*?)" for review$/) do |number_of_due_points|  
  select 'number_of_points', number_of_due_points
  click 'start_review'
  ajax_complete?
end
When(/^I confirm that I have finished reviewing those points$/) do
  click 'finish_review'
end
Then(/^I see "(.*?)" shown$/) do |number_of_due_points|
  expect(find("#due_points")).to have_text(/#{number_of_due_points}/)
end