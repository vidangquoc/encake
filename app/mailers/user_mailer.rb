class UserMailer < ApplicationMailer
  
  def confirm_registration(user)
    @user = user
    @confirm_url = "#{root_url}#confirm_registration?email=#{CGI.escape(@user.email)}&confirmation_hash=#{CGI.escape(@user.confirmation_hash)}"
    mail to: @user.email, subject: "Tài khoản mới của bạn"
  end
  
  def recover_password(user)
    @user = user
    mail to: @user.email, subject: "Khôi phục mật khẩu của bạn"
  end
  
end
