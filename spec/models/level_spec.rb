require 'spec_helper'

describe Level do
  
  describe 'validations' do
    
    subject do
      FactoryBot.create(:level)
    end      
    
    it { is_expected.to validate_presence_of(:highest_score) }       
    
    it { should validate_numericality_of(:highest_score).only_integer }    
    
    context 'highest score should be greater than 0' do
      
      level = FactoryBot.create(:level)
      
      (0..-1).each do |highest_score|
        level.highest_score = highest_score
        expect(level).not_to be_valid
        expect(level.errors.error_types[:highest_score]).to include?(:greater_than)
      end
      
    end        
    
  end
  
  describe 'methods' do
    
     before :each do
        5.Levels
        @level1, @level2, @level3, @level4, @level5 = Level.order('highest_score ASC').limit(5)
      end
    
    describe "get_level_for_score" do
                 
      it "returns the right level for the score" do        
        expect(Level.get_level_for_score(@level1.highest_score + 1).id).to be @level2.id
        expect(Level.get_level_for_score(@level2.highest_score).id).to be @level2.id
      end
      
      it "returns the last level if the score exceeds highest score of the last level" do
        expect(Level.get_level_for_score(@level5.highest_score + 1).id).to be @level5.id
      end
      
    end
    
    describe "around_levels" do
      
      it "returns the level and the two nearest around levels" do
        expect(@level3.around_levels.map(&:id)).to eq [@level2, @level3, @level4].map(&:id)
      end
      
      it "sets previous level nil if the current level is the first level" do       
        expect(@level1.around_levels.first).to be nil
      end
      
      it "sets next level nil if the current level is the last level" do       
        expect(Level.order('highest_score ASC').last.around_levels.last).to be nil
      end
      
    end
    
  end
  
end
