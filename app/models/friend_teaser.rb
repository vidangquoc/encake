class FriendTeaser < ActiveRecord::Base
  validates :teasing_phase, presence: true
  validates :selected_times, presence: true
  strip_attributes collapse_spaces: true
end

class << FriendTeaser
  def increase_selected_times(teaser_id)
    teaser = FriendTeaser.find(teaser_id) rescue nil
    if !teaser.nil?
      teaser.selected_times = teaser.selected_times + 1
      teaser.save!
    end
  end
end
