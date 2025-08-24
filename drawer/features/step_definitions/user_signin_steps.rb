Given(/^I have an account$/) do
  @user = User.one.belongs_to(Level.one).belongs_to_current_lesson(Lesson.one)
end

Given(/^My account has not been activated$/) do
  @user.update_attribute :status, User::STATUSES[:not_confirmed]
end
When(/^I sign in$/) do      
  submit_signin(@user)
end
Then(/^I'm told that my account has not been activated$/) do
  has_error_on :base, :not_activated
end

When(/^I sign in with correct email and password$/) do
  submit_signin(@user, :signin_username => @user.email)
end
Then(/^I get signed in$/) do
  expect(page).to have_css('.signout')
end

When(/^I sign in with incorrect email$/) do
  submit_signin(@user, :signin_username => 'incorect_email@abc.com')
end
Then(/^I'm told that the login is invalid$/) do
  has_error_on :base, :signin_invalid
end

When(/^I sign in with incorrect password$/) do
  submit_signin(@user, :signin_password => 'incorrect_password')
end


