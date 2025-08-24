class ApplicationController < ActionController::Base
  respond_to :html, :json
  protect_from_forgery
  skip_before_action :verify_authenticity_token, if: :json_request?
  before_filter :authenticate
  
  include ApplicationHelper
  include SessionsHelper
  
  protected
  
  def json_request?    
    request.format.json?
  end
  
end
