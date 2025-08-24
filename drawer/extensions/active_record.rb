class ActiveRecord::Base   
      
  def first_error(keys=[])
    errors.first_error(keys)
  end
    
end
  
  
