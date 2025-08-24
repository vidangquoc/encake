class OvercomeFriendMailer < ApplicationMailer
  
  def notify(notification)
    @to_user = notification.to_user
    @from_user = notification.from_user
    @score_diff = notification.data.fetch(:score_diff)
    @teaser_id = notification.data[:teaser_id]
    @teaser = FriendTeaser.find_by id: @teaser_id
    template_name = @teaser.nil? ? "notify" : "notify_with_teaser"
    subject = if @teaser.nil? then
                "#{@from_user.first_name} đã vượt qua bạn"
              else
                "Cấp báo! #{@from_user.first_name} đã '#{@teaser.teasing_phase}' bạn"
              end
    
    mail({
      to: @to_user.email,
      subject: subject,
      template_name: template_name    
    })
    
  end
  
end