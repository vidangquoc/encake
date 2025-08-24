module ActiveModel
  class Errors      
    
    def error_types
      @_error_types ||= { }
    end
               
    def to_hash_with_types
      hash = {}      
      error_types.each_key do |attribute|                   
        hash[attribute] = Hash[ error_types[attribute].zip self[attribute] ]          
      end
      hash
    end
    
    def first_error(attributes=[])      
      errors = to_hash_with_types      
      if attributes.any?
        attributes.each do |attribute|      
          if errors.any? {|key, messages| key == attribute.to_sym}
            error = errors[attribute]
            return ErrorMessage.new *([attribute,  error.first.to_a].flatten)
          end
        end
      else
        if errors.any?
          error = errors.first      
          return ErrorMessage.new *([error[0], error[1].first.to_a].flatten)
        end      
      end
      nil
    end
    
    private
    
    def add_with_save_types(attribute, message = nil, options = {})
      message ||= :invalid
      if message.is_a?(Proc)
        message = message.call
      end
      error_types[attribute] ||= []
      error_types[attribute] << message
      add_without_save_types(attribute, message, options)
    end        
    alias_method_chain :add, :save_types
    
    def clear_with_clear_types()
      @_error_types = {}
      clear_without_clear_types
    end    
    alias_method_chain :clear, :clear_types
      
  end
  
  class ErrorMessage
    attr_accessor :on_attribute, :type, :message
    def initialize(on_attribute, type, message)
      self.on_attribute, self.type, self.message = on_attribute, type, message      
    end
    def ==(other)
      (on_attribute == other.on_attribute && type == other.type && message == other.message)
    end
  end  
  
end