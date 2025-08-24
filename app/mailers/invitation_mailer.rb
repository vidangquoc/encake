class InvitationMailer < ApplicationMailer
  
  def invite(sender, email)
    @sender = sender
    @url = root_url
    mail to: email, subject: "#{sender.email} muốn cùng bạn thi đua trên encake.com"
  end
  
end
