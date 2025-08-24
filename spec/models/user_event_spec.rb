require 'spec_helper'

describe UserEvent do
  
  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
  end
  
  describe "callbacks" do    
    it "calls #process method" do
      event = UserEvent.new user_id: 1
      expect(event).to receive(:process)
      event.save
    end
  end
  
end
