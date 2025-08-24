class UserAction < ActiveRecord::Base
  
  serialize :data, Hash
  
  belongs_to :user
  
  has_many :events, class_name: 'UserEvent', foreign_key: :from_action_id
  
  has_many :notifications, through: :events
  
  after_create :process
  
  def process
    detect_and_create_reach_new_level_event
    detect_and_create_overcome_friend_events
    pass_friend_teaser_to_notifications if self.data[:teaser_id]
  end  
  
  def overcome_friends
    find_overcome_friends
  end
  
  def action_type
    self.class.name
  end
  
  def pass_friend_teaser_to_notifications
    notifications.each do |notification|
      if notification.instance_of?(NotificationOvercomeFriend) && notification.data[:teaser_id].nil?
        notification.defer_until = DateTime.now
        notification.data[:teaser_id] = self.data[:teaser_id]
        notification.save
      end
    end
  end
  
  private
  
  def detect_and_create_reach_new_level_event
    
    old_level = Level.find(data.fetch(:old_level_id))
    new_level = Level.find(data.fetch(:new_level_id))
    
    if new_level.highest_score > old_level.highest_score
      
      UserReachNewLevelEvent.create user_id: user_id, from_action_id: self.id, data: {new_level_id: new_level.id}
      
    end
    
  end
  
  def detect_and_create_overcome_friend_events
    find_overcome_friends.each do |friend|
      UserOvercomeFriendEvent.create user_id: user.id, from_action_id: self.id, data: {friend_id: friend.id, score_diff: user.score - friend.score}
    end
  end
  
  def find_overcome_friends
    score_change = data.fetch(:score_change)
    user.friends.where(["score >= ? AND score < ?", user.score - score_change, user.score]).to_a
  end
  
end
