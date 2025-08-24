require 'yaml'

class ConstantLoader
  
  def self.load(file)
    
    constants = {}
    
    yaml_values = YAML.load_file(file)
    
    yaml_values.each do |key, value|
      
      if value.is_a?(Hash) and !value[Rails.env].nil?
        
        constants[key] = value[Rails.env]
        
      else
        
        constants[key] = value
        
      end
      
    end
       
    RecursiveOpenStruct.new(constants)
    
  end
   
end

