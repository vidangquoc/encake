class AdministratorMailer < ApplicationMailer
  
  def notify(subject, body)
    @body = body
    mail to: Constants.admin_email, subject: subject
  end
    
end
