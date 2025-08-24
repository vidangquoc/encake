module FormBase
  
  def signin(user)    
    visit signin_path
    fillin 'signin_username', user.email
    fillin 'signin_password', user.password
    find("#signin_submit").click
  end      
  
  def submit_form(fields, overides)
           
    fields = fields.merge overides
    fields.each do |field, action_value|   
      take_action_on_field(field, action_value)
    end
    
  end
    
  def take_action_on_field(field, action_value)
  
    if action_value.kind_of? Array
      
      act = action_value[0]
      value = action_value[1]
      
    elsif action_value.kind_of? Symbol
      
      act = action_value
      value = ""
      
    else
      
      act = :fillin
      value = action_value
      
    end
    
    field = field.to_s
    
    case act.to_sym
      
    when :fillin
      
      fillin field, value
      
    when :select
      
      sellect field, value
      
    when :choose
      
      choose "#{field}_#{value}"
      
    when :check
      
      check field
      
    when :click
      
      click field
      
    when :attach
      
      attach_file field, value
      
    end
    
  end
  
end

World FormBase