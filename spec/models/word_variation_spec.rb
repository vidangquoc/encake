require 'spec_helper'

RSpec.describe WordVariation, type: :model do
  
  describe 'validations' do
    
    subject do
      FactoryBot.create :lesson
    end      
    
    it { is_expected.to validate_presence_of :content }
    
  end
  
end
