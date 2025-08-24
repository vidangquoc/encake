class Invitation < ActiveRecord::Base
  
  strip_attributes collapse_spaces: true
  
  belongs_to :sender, :foreign_key => :sender_id, :class_name => 'User'
  
  after_create :send_mail    
  
  GOOD_MAIL_PROVIDERS = %w{gmail yahoo hotmai outlook}
  
  private
  
  def send_mail
    InvitationMailer.delay.invite(self.sender, self.receiver_email)
  end   
  
end

class << Invitation

  def get_email_importer(email)
    return 'gmail' if email =~ /@gmail(.\w+)+$/
    return 'yahoo' if email =~ /@yahoo(.\w+)+$/
    nil
  end
  
  def find_inviter_for_user(user)
    where(:receiver_email => user.email).first.sender rescue nil
  end
  
  def exclude_invalid_emails(emails)    
    emails.select{ |email| email =~ User::EMAIL_FORMAT }
  end
  
  def pick_out_good_emails(emails)
    emails.select do |email|
      Invitation::GOOD_MAIL_PROVIDERS.any? do |provider|
        email.include?(provider)
      end
    end
  end
  
  def parse_emails(emails_string)
    emails_string.split("\n").map{|line| line.strip}.select{|line| !line.blank?}
  end
  
end