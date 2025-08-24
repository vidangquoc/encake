#class ContactsController < ApplicationController
#  def callback
#    @contacts = request.env['omnicontacts.contacts']
#    puts "List of contacts obtained from #{params[:importer]}:"
#    contacts = ""
#    @contacts.each do |contact|
#      contacts += "Contact found: name => #{contact[:name]}, email => #{contact[:email]}<br/>"
#    end
#    render :text => contacts
#  end
#  
#  def failure    
#    flash[:notice] = params[:message] # if using sinatra-flash or rack-flash
#    redirect_to root_path
#  end  
#  
#end
