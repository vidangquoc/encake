require 'rails_helper'

RSpec.describe BadgeType, type: :model do
  
  #VALIDATIONS
  it { is_expected.to validate_presence_of :badge_type }
  it { is_expected.to validate_presence_of :name}
  it { is_expected.to validate_presence_of :number_of_efforts_to_get }
  it { is_expected.to validate_inclusion_of(:badge_type).in_array( BadgeType::BADGE_TYPES )}
  
  #METHODS
  describe "next_badge_type" do
    
    before :each do
      create_badge_types
    end
    
    it "returns the next sub type" do
      
      badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").first(2).last
      next_badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").first(3).last
      
      expect(badge_type.next_badge_type.id).to eq next_badge_type.id
      
    end
    
    it "returns nil if there is no next sub type" do
      
      badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").last
      
      expect(badge_type.next_badge_type).to be nil
      
    end
    
  end
  
end
