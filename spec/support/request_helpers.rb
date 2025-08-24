module Request
  
  module JsonHelpers
    def json_response
      @json_response ||= begin
        json_response = JSON.parse(response.body, symbolize_names: true)
        if(json_response.kind_of?(Array))
          json_response.map{|item| Hashugar.new(item) }
        else
          Hashugar.new(json_response)
        end
      end
    end
  end
  
  module HeadersHelpers
    
    def api_response_format(format = Mime::JSON)
      request.headers['Accept'] = "#{request.headers['Accept']},#{format}"
      request.headers['Content-Type'] = format.to_s
    end
    
  end
  
  module SessionsHelpers
    
    def sign_in(user)
      auth_token = AuthenticationToken.create_for_user(user)
      request.headers['AUTH-USER-ID'] = user.id
      request.headers['AUTH-TOKEN'] = auth_token
      auth_token
    end
    
    def sign_in_a_user()
      user = User.one
      auth_token = AuthenticationToken.create_for_user(user)
      request.headers['AUTH-USER-ID'] = user.id
      request.headers['AUTH-TOKEN'] = auth_token
      user
    end
    
  end
  
  module TranslationHelpers
    def validation_error_on(on)
      model, field, validation_type = on.split('.')
      I18n.t("activerecord.errors.models.#{model}.attributes.#{field}.#{validation_type}")
    end
  end
  
end