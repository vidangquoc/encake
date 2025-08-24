#Rails.application.middleware.use OmniContacts::Builder do
  #importer :gmail, "client_id", "client_secret", {:redirect_path => "/oauth2callback", :ssl_ca_file => "/etc/ssl/certs/curl-ca-bundle.crt"}
  #importer :yahoo, "consumer_id", "consumer_secret", {:callback_path => '/callback'}
  #importer :hotmail, "client_id", "client_secret"
  
  # yahoo
#  yahoo_consumer_id = Constants.yahoo_mail_contacts.consumer_id
#  yahoo_consumer_secret = Constants.yahoo_mail_contacts.consumer_secret
#  importer :yahoo, yahoo_consumer_id, yahoo_consumer_secret
  
  # gmail
#  gmail_client_id = Constants.gmail_contacts.client_id
#  gmail_client_secret = Constants.gmail_contacts.client_secret
#  importer :gmail, gmail_client_id, gmail_client_secret, :max_results => 1000
  
#end