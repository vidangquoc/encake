class MainController < ApplicationController
  
  force_ssl if: :ssl_configured?
  skip_before_filter :authenticate
  caches_page :index
  
  def index
  end
  
  def html_convert
  end
  
  def test
  end
  
  def react
    @some_props = {}
  end
  
  private
  
  def ssl_configured?
    Rails.env.production?
  end
  
end
