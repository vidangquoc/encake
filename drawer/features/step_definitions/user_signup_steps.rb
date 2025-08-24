#encoding: utf-8
Given(/^I am ready with all valid details for signup$/) do
  2.Levels
  Level.serial_update :number => [1,2]
  2.Lessons.belongs_to([Level.first])
  @details = FactoryGirl.build :user
end
# 
When(/^I signup with all valid details$/) do  
  submit_signup @details
end
Then(/^My account is created$/) do
  expect(User.count).to be_equal(1)
end
And(/^My level is the first level$/) do
  expect(User.last.level.id).to eq Level.where(:number=>1).first.id
end
And(/^My lesson is the first lesson of the first level$/) do
  expect(User.last.current_lesson.id).to eq Level.where(:number=>1).first.lessons.where(:position => 1).first.id
end
But(/^My account is not activated$/) do
  User.last.status == User::STATUSES[:not_confirmed]
end
Then(/^I'm reminded to open my email to confirm my account$/) do
  expect(current_path).to eq remind_confirmation_path
end
And(/^I receives a confirmation email$/) do
  open_last_email  
  expect(current_email).to deliver_to(@details.email)
end
Then(/^The email contains confirmation link$/) do
  expect(current_email).to have_body_text(/#{confirm_registration_path}/)
end
Given(/^I follow confirmation link$/) do
   click_email_link_matching(/#{confirm_registration_path}/)
end
Then(/^My account is activated$/) do
  expect(User.find_by_email(@details.email).status).to be_equal User::STATUSES[:active]
end
And(/^I'm signed in$/) do  
  expect(page).to have_css('.signout')
end
#
Given(/^I sign up with a nickname containing uppercase letters$/) do
  @details.nickname = 'NICKNAME'
  submit_signup @details
end
Then(/^The nickname becomes all\-lowercase$/) do
  expect(User.last.nickname).to eq @details.nickname.downcase
end
#
When(/^I sign up without an email$/) do  
  submit_signup @details, :user_email => ''
end
Then(/^I'm told that email is required$/) do
  has_error_on(:email, :blank)
end
#
When(/^I sign up with an invalid email$/) do  
  submit_signup @details, :user_email => 'invalid@enetwork'
end
Then(/^I'm told that email is invalid$/) do
  has_error_on(:email, :invalid)
end
#
When(/^I sign up with an email that has been registered$/) do
  FactoryGirl.create :user    
  submit_signup @details, :user_email => User.last.email
end
Then(/^I'm told that the email has been used$/) do
  has_error_on :email, :taken
end
#
When(/^I sign up without a nickname$/) do  
  submit_signup @details, :user_nickname => ''
end
Then(/^I'm told that nickname is required$/) do
  has_error_on :nickname, :blank
end
#
When(/^I sign up with a nickname having less than (\d+) characters$/) do |min|  
  submit_signup @details, :user_nickname => 'a'*(min.to_i-1)
end
Then(/^I'm told that nickname is too short$/) do
  has_error_on :nickname, :too_short
end
#
When(/^I sign up with a nickname having more than (\d+) characters$/) do |max|  
  submit_signup @details, :user_nickname => 'a'*(max.to_i+1)
end
Then(/^I'm told that nickname is too long$/) do
  has_error_on :nickname, :too_long
end
#
When(/^I sign up with a nickname containing invalid characters$/) do  
  submit_signup @details, :user_nickname => 'abc.123'
end
Then(/^I'm told that nickname is invalid$/) do
  has_error_on :nickname, :invalid
end
#
When(/^I sign up with an nickname that has been registered$/) do
  FactoryGirl.create :user  
  submit_signup @details, :user_email => 'another@abc.com', :user_nickname => User.last.nickname.upcase  
end
Then(/^I'm told that the nickname has been used$/) do
  has_error_on :nickname, :taken
end
#
When(/^I sign up without password$/) do  
  submit_signup @details, :user_password => ''
end
Then(/^I'm told that password is required$/) do
  has_error_on :password, :blank
end
#
When(/^I sign up with a password having less than (\d+) characters$/) do |min|  
  submit_signup @details, :user_password => 'a'*(min.to_i-1)
end
Then(/^I'm told that password is too short$/) do
  has_error_on :password, :too_short
end
#
When(/^I sign up with a password having more than (\d+) characters$/) do |max|  
  submit_signup @details, :user_password => 'a'*(max.to_i+1)
end
Then(/^I'm told that password is too long$/) do
  has_error_on :password, :too_long
end
#
When(/^I sign up with a password containing non\-ascii characters$/) do  
  submit_signup @details, :user_password => 'Vĩđạica'
end
Then(/^I'm told that password is invalid$/) do
  has_error_on :password, :invalid
end
#
When(/^I sign up with a password confirmation not matching password$/) do  
  submit_signup @details, :user_password_confirmation =>  'not_match_password'
end
Then(/^I'm told that password confirmation does not match$/) do
  has_error_on :password_confirmation, :confirmation
end
#
Given(/^I sign up without choosing a gender$/) do
  submit_signup @details, :user_gender => :leave_alone
end
Then(/^I'm told that gender is required$/) do
  has_error_on :gender, :blank
end

When(/^I sign up with an avatar image file, extension of which is not allowed$/) do
  submit_signup @details, :user_avatar  => [:attach, Rails.root.join('spec','factories','sample_images/invalid.exe')]
end
Then(/^I'm told that I am not allowed to upload file with that extension$/) do
  has_tag_with_id('span', 'avatar_error')
end

When(/^I sign up without first name$/) do
  submit_signup @details, :user_first_name => ''
end
Then(/^I'm told that first name is required$/) do
  has_error_on :first_name, :blank
end

When(/^I sign up without last name$/) do
  submit_signup @details, :user_last_name => ''
end
Then(/^I'm told that last name is required$/) do
  has_error_on :last_name, :blank
end


