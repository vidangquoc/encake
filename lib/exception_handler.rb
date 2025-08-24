class ExceptionHandler
end

class << ExceptionHandler
  
  def ignore(&block)
    begin
      if block_given?
        block.call  
      end
    rescue Exception => ex
      handle(ex)
    end
  end
  
  def handle(ex, info = {})
    begin
      AdministratorMailer.delay.notify("An exception encountered on server", {error_message: ex.message, error_trace: ex.backtrace, info: info}.to_json)
    rescue #ignore any exceptions caused by exception notifier
    end
  end
  
end