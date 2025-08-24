Given(/^I visit direct inviting page$/) do
  visit direct_invite_path
end
Given(/^I enter several email addresses$/) do
  @first_mail = 'a@example.com'
  @second_mail = 'b@example.com'
  fillin_emails [@first_mail, @second_mail]
  
end
Given(/^I click the button to invite friends$/) do
  click 'invite_friends'
end
Then(/^I'm redirected to home page$/) do
  expect(current_path).to eq root_path
end
Then(/^I see a message telling me that invitations has been sent$/) do
  has_tag_with_id("span", "invitations_sent")
end
Then(/^invitation emails is sent to the email addresses I entered$/) do
  expect(ActionMailer::Base.deliveries.count).to be_equal(2)
end
Then(/^the emails contain link to enetwork$/) do
  open_last_email
  expect(current_email).to have_body_text(/users\/new/)
end

Given(/^I let the textbox for entering email addresses empty$/) do
  fillin_emails []
end
Then(/^I should see a messaging telling me that I should enter email addresses$/) do
  has_tag_with_id("span", "email_addresses_required")
end

Given(/^I enter some valid email addresses and some invalid email addresses$/) do
  @valid_email1, @valid_email2 = 'abc@abc.com', 'abc@abc.com.vn'
  @invalid_email1, @invalid_email2 = 'abc@abc@com', 'abc@abc;com'  
  fillin_emails [@valid_email1, @valid_email2, @invalid_email1, @invalid_email2]
end
Then(/^only valid email addresses receive invitation emails$/) do
  expect(ActionMailer::Base.deliveries.count).to be 2
  expect(find_email(@valid_email1)).not_to be_nil
  expect(find_email(@valid_email2)).not_to be_nil
end
Then(/^I see a message telling me that some email addresses are invalid$/) do
  has_tag_with_id("span", "invalid_email_addresses")
end
Then(/^invalid email addresses are presented in the textbox$/) do
  
  expect(page.evaluate_script(" $('#invited_emails').val() ")).to eq [@invalid_email1, @invalid_email2].join(",")

end

def fillin_emails(emails)
  page.execute_script(" $('#invited_emails').tokenfield('setTokens', '#{emails.join(',')}'); ")  
end