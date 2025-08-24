Given(/^My email is from a supported email service provider$/) do
  @user.update_attribute(:email, 'example@gmail.com')
end
Given(/^I have some emails in my contact list/) do
  @contacts = ['email1@example.com', 'email2@example.com', 'email3@example.com', 'email4@example.com', 'email5@example.com']  
  OmniContacts.integration_test.mock(:gmail, @contacts.map{|email| {email: email} })
end
When(/^I visit invite friend page$/) do
  OmniContacts.integration_test.enabled = true
  visit invite_path
end
Then(/^I see checkboxes for me to choose the email addresses$/) do   
  @contacts.each do |email|
    has_tag_with_text('label', email)
  end 
end
Given(/^I choose an email address$/) do
  @choosen_email = @contacts.sample
  check @choosen_email  
end
Given(/^I confirm the invitations$/) do
  click "send_invitations"
end
Then(/^an invitation email is sent to the email address I chose$/) do
  expect(ActionMailer::Base.deliveries.count).to be 1
  open_last_email  
  expect(current_email).to deliver_to(@choosen_email)
end
Then(/^the email contains link to enetwork$/) do
  expect(current_email).to have_body_text(root_path)
end


Given(/^I have no emails in my contact list$/) do 
  OmniContacts.integration_test.mock(:gmail, [])
end
Then(/^I'm redirected back to direct inviting page$/) do
  expect(current_path).to eq direct_invite_path
end


Given(/^I invited a friend through and invitation email$/) do
  Level.one; Lesson.one
  @user = FactoryGirl.create(:user)
  @friend = FactoryGirl.build :user, :email => "friend@abc.com"
  @user.invitations.create! :receiver_email => @friend.email
end
Given(/^My friend opens the email and clicks the link to enetwork$/) do
  open_last_email
  click_email_link_matching(/#{root_path}/)
end
Then(/^He is lead to enetwork home page$/) do
  expect(current_path).to eq new_user_path
end
Given(/^He visit the registration page$/) do
  visit signup_path
end
Given(/^He registers with all valid information$/) do  
  submit_signup @friend
end
Then(/^His account is created$/) do
  expect(User.last.email).to eq @friend.email
end
Given(/^He opens his confirmation email and clicks on confirmation link$/) do
  open_last_email
  click_email_link_matching(/#{confirm_registration_path}/)
end
Then(/^His account is activated$/) do
  @friend_saved = User.find_by_email(@friend.email)
  expect(@friend_saved.is_status_active?).to be true  
end
Then(/^We become friends on enetwork$/) do    
  expect(@friend_saved).to be_friend_with(@user)
  expect(@user).to be_friend_with(@friend_saved)
end

Given(/^Some of the emails belong to my friends$/) do  
  @friend_emails = @contacts.sample(2)
  friends = User.has( @friend_emails.map{|friend_email| {email: friend_email} } )
  @user.has_friendships( friends.map{ |friend| {friend_id: friend.id} } )  
end

Then(/^I don't see emails of my friends on available email list$/) do
  available_emails = get_texts('email')
  expect((available_emails & @friend_emails)).to be_empty
end

Given(/^I choose some emails to invite$/) do
  @choosen_emails = @contacts.sample(4)
  @choosen_emails.each {|email| check email  }  
end
Given(/^Some of the emails have already registered$/) do
  @registered_emails = @choosen_emails.sample(2)
  User.has @registered_emails.map{ |email| {email: email} }
end
Then(/^Those people who have the registered emails become my friends$/) do
  @registered_emails.each do |email|
    expect(@user.friends.map(&:email).include?(email)).to be true
  end
end
Then(/^Invitation emails are only sent to unregisted emails$/) do  
  to_emails = ActionMailer::Base.deliveries.map{ |to_mail| to_mail.to.first } 
  expect(to_emails.sort).to eq (@choosen_emails - @registered_emails).sort
end

Given(/^My email is not from a supported email service provider$/) do
  @user.update_attribute :email, 'vidaica@not_supported.com'
end

Given(/^My contact list contains some invalid emails$/) do
  @invalid_emails = ['invalid1', 'invalid2']
  @contacts = ['email1@example.com', 'email2@example.com'] + @invalid_emails
  OmniContacts.integration_test.mock(:gmail, @contacts.map{|email| {email: email} })
end
Then(/^I don't see invalid emails on available email list$/) do
  available_emails = get_texts('email')
  expect((available_emails & @invalid_emails)).to be_empty
end



