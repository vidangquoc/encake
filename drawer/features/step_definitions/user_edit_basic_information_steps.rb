Given(/^I want to update my basic information$/) do
  @user = User.one.belongs_to(Level.one).belongs_to_current_lesson(Lesson.one)
  signin @user
end

When(/^I update my basic information with all valid details$/) do  
  submit_basic_information @user
end

Then(/^I should see a message telling me that information has been updated$/) do
  has_tag_with_id("span", "update_basic_information_success")
end

When(/^I update basic information with a password having less than (\d+) characters$/) do |number_of_characters|
  submit_basic_information @user, user_password: 'a'*( number_of_characters.to_i - 1 )
end

Then(/^A message show me that password is too short$/) do
  has_error_on :password, :too_short
end

When(/^I update basic information with a password having more than (\d+) characters$/) do |number_of_characters|
  submit_basic_information @user, user_password: 'a'*( number_of_characters.to_i + 1 )
end

Then(/^A message show me that password is too long$/) do
  has_error_on :password, :too_long
end

When(/^I update basic information with a password containing non-ascii characters$/) do
  submit_basic_information @user, user_password: 'vĩđạica'
end

Then(/^A message show me that password is invalid$/) do
  has_error_on :password, :invalid
end

When(/^I update basic information with a password confirmation not matching password$/) do
  submit_basic_information @user, user_password: 'password', user_password_confirmation: 'notmatch'
end

Then(/^A message show me that password confirmation does not match$/) do
  has_error_on :password_confirmation, :confirmation
end

Given(/^I update basic information with a new email$/) do
  @email_before = @user.email
  submit_basic_information @user, user_email: 'another@example.com'
end

Then(/^My email still keeps unchanged$/) do
  expect(@user.reload.email).to eq @email_before
end

Given(/^I update basic information with a blank password$/) do
  @hashed_password_before = @user.hashed_password
  submit_basic_information @user, user_password: '', user_password_confirmation: ''
end

Then(/^My password is unchanged$/) do
  expect(@user.reload.hashed_password).to eq @hashed_password_before
end

When(/^I update basic information without first name$/) do
  submit_basic_information @user, user_first_name: ''
end

Then(/^A message show me that first name is required$/) do
  has_error_on :first_name, :blank
end

When(/^I update basic information without last name$/) do
  submit_basic_information @user, user_last_name: ''
end

Then(/^A message show me that last name is required$/) do
  has_error_on :last_name, :blank
end

When(/^I update my avatar with a file, extension of which is not allowed$/) do
  submit_basic_information @user, :user_avatar  => [:attach, Rails.root.join('spec','factories','sample_images/invalid.exe')]
end

Then(/^A message show me that I am not allowed to upload file with that extension$/) do
  has_tag_with_id('span', 'avatar_error')
end



