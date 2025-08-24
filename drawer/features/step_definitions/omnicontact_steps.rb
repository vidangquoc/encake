#Given(/^My registered "(.*?)" is from a supported email service "(.*?)"/) do |email_address, provider|
#  @provider = provider
#  @user.update_attribute(:email, email_address)
#end
#And(/^I have some emails in my contact list$/) do
#  @contacts = if @provider == 'gmail'
#                ['hocthuoclongtienganh@yahoo.com','hocthuoclongtienganh2@yahoo.com', 'laogiangongan@yahoo.com', 'nhucam@yahoo.com']
#              else
#                ['hocthuoclongtienganh@gmail.com','hocthuoclongtienganh2@gmail.com']              
#              end
#end
#Then(/^I'm redirected to my email service provider's login page$/) do   
#expect(#  current_url).to include( @provider == 'gmail' ? 'google' : 'yahoo' )  
#end
#Given(/^I fill in login form with my email and "(.*?)"$/) do |password|
#  
#  sleep 5 # wait for the page to fully loaded
#  if @provider == 'gmail'
#    fillin 'Email', @user.email
#    fillin 'Passwd', password
#  else
#    fillin 'username', @user.email
#    fillin 'passwd', password
#  end
#  
#end
#Given(/^I confirm the login$/) do
#  click ( @provider == 'gmail' ? 'signIn' : '.save' )   
#end
#Then(/^I give permission to get my contacts$/) do
#  if @provider == 'gmail'
#    click 'submit_approve_access' if page.has_css?('#submit_approve_access')
#  else
#    sleep 5 # wait for the page to fully loaded
#    click 'agree'
#  end
#end
#Then(/^I'm redirected back to enetwork$/) do   
#expect(#  current_path).to eq contacts_callback_path(:importer => @provider)  
#end