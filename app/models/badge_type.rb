class BadgeType < ActiveRecord::Base
  
  strip_attributes collapse_spaces: true
  
  BADGE_TYPES = %w{diligent warrior social lucky_star}
  
  validates_presence_of :badge_type, :name, :number_of_efforts_to_get
  
  validates_inclusion_of :badge_type, in: BadgeType::BADGE_TYPES
  
  mount_uploader :image, BadgeTypeImageUploader
  
  def next_badge_type
    BadgeType.where(badge_type: self.badge_type).where(["number_of_efforts_to_get > ?", self.number_of_efforts_to_get]).order("number_of_efforts_to_get ASC").first
  end
  
end
