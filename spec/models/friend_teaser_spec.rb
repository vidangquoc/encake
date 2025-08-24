require 'spec_helper'

describe FriendTeaser do
  
  describe 'validations' do
    it { is_expected.to validate_presence_of :selected_times }
    it { is_expected.to validate_presence_of :teasing_phase }
  end
  
  describe 'methods' do
    
    describe 'Class#increase_selected_times' do
      
      it 'increases the number of selected times by one' do
        
        teaser = FriendTeaser.one
        
        expect(teaser.selected_times).to be 0
        FriendTeaser.increase_selected_times(teaser.id)
        expect(teaser.reload.selected_times).to be 1
        
      end
      
    end
    
  end
  
end