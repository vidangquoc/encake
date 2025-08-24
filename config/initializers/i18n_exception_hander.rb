# only for development and test
if ! Rails.env.production?
  
  module I18n
    class JustRaiseExceptionHandler < ExceptionHandler
      def call(exception, locale, key, options)
        if exception.is_a?(MissingTranslation)
          raise exception.to_exception
        else
          super
        end
      end
    end
  end
   
  I18n.exception_handler = I18n::JustRaiseExceptionHandler.new

end