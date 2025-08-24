class BaseController < ActionController::Base
  
  rescue_from ::Exception, with: :handle_exception
  
  respond_to :json
  
  #protect_from_forgery with: :null_session
  
  before_filter :authenticate
  
  #before_filter :raise_exception
  before_filter :delay
  
  include Authenticable
  
  private
  
  def handle_exception(ex)
    ExceptionHandler.handle(ex, {url: request.url, params: request.filtered_parameters})
    render json: {message: ex.message}, status: 500
  end
  
  def delay
    if(Rails.env.development?)
      #sleep 2
    end
  end

  def raise_exception
    if(Rails.env.development?)
      raise Exception.new("TEST!")
    end
  end
  
end
