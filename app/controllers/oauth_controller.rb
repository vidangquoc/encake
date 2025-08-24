class OauthController < ApplicationController
  
  def handler
        
        
    email = auth_hash[:info][:email]
    access_token = auth_hash[:credentials][:token]
    
    imap = Net::IMAP.new('imap.gmail.com', 993, usessl = true, certs = nil, verify = false)
    imap.authenticate('XOAUTH2', email, access_token)
    imap.select('INBOX')
    
    imap.search(["ALL"]).each do |message_id|
      envelope = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]      
    end
    
    #imap.search(['ALL']).each do |message_id|
    #
    #    msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
    #    mail = Mail.read_from_string msg
    
        #puts mail.subject
        #puts mail.text_part.body.to_s
        #puts mail.html_part.body.to_s       
        
    
    #end
    
    
    render :text => "ok"
    
    
  end
  
  #get '/auth/failure' do
  #  flash[:notice] = params[:message] # if using sinatra-flash or rack-flash
  #  redirect '/'
  #end
  
  def failure
    flash[:notice] = params[:message] # if using sinatra-flash or rack-flash
    redirect_to root_path
  end

  
  private
  
  def auth_hash
    request.env['omniauth.auth']
  end
  
end
