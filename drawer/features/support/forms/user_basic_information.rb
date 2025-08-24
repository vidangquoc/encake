module UserBasicInformationForm  
  
  def submit_basic_information (details, overides={})
           
    visit basic_information_path
    
    fields = {
      :user_first_name  => details.first_name,
      :user_last_name  => details.last_name,
      :user_middle_name  => details.middle_name,
      :user_email  => details.email,      
      :user_password => details.password,
      :user_password_confirmation => details.password,
      :user_gender => [:choose, details.gender],
      :user_avatar  => [:attach, Rails.root.join('spec','factories','sample_images/lovely_woman.jpeg')],
      :update_user_information => :click
    }
       
    submit_form(fields, overides)
    
  end 
   
end

World UserBasicInformationForm