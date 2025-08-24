module SignupForm  
  
  def submit_signup (details, overides={})
           
    visit signup_path
    
    fields = {
      :user_first_name => details.first_name,
      :user_last_name => details.last_name,
      :user_middle_name => details.middle_name,
      :user_email  => details.email,      
      :user_password => details.password,      
      :user_gender => [:choose, details.gender],
      :user_avatar => [:attach, Rails.root.join('spec','factories','sample_images/lovely_woman.jpeg')],
      :create_user => :click
    }
       
    submit_form(fields, overides)
    
  end 
   
end

World SignupForm