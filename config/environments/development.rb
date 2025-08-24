Enetwork::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
  
  # eager loading libraries
  config.eager_load = false
  
  config.serve_static_files = true
  
  Rails.application.routes.default_url_options[:host] = 'localhost:3000'
       
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = false
  
  #config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  #config.action_mailer.smtp_settings = {
  #  :address              => "smtp.gmail.com",
  #  :port                 => 587,
  #  :domain               => 'encake.com',
  #  :user_name            => 'hocthuoclongtienganh',
  #  :password             => 'vidaica.vidaica',
  #  :authentication       => 'plain',
  #  :enable_starttls_auto => true
  #}    
  
  #action mailer
  config.action_mailer.default_url_options = { :host => 'http://localhost:3000' }  
  config.action_mailer.smtp_settings = {
    authentication: :plain,
    address: "smtp.mailgun.org",
    port: 587,
    domain: "encake.com",
    user_name: 'postmaster@sandbox13744.mailgun.org',
    password: '9pywaswdvcv4',
    openssl_verify_mode: 'none',
    enable_starttls_auto: true
  }
  
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    #Bullet.growl = true
    #Bullet.xmpp = { :account  => 'bullets_account@jabber.org',
    #                :password => 'bullets_password_for_jabber',
    #                :receiver => 'your_account@jabber.org',
    #                :show_online_status => true }
    Bullet.rails_logger = true
    #Bullet.honeybadger = true
    #Bullet.bugsnag = true
    #Bullet.airbrake = true
    #Bullet.rollbar = true
    Bullet.add_footer = true
    #Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
    #Bullet.stacktrace_excludes = [ 'their_gem', 'their_middleware' ]
    #Bullet.slack = { webhook_url: 'http://some.slack.url', foo: 'bar' }
  end
  
end
