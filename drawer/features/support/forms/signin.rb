module SigninForm
  
  def submit_signin (user, overides={})
    
    visit signin_path
   
    fields = {
      :signin_username  => user.email,
      :signin_password => user.password,
      :signin_submit => :click
    }
       
    submit_form(fields, overides)
    
  end
  
end

World SigninForm