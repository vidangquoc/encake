require 'spec_helper'

describe ExampleAlternative do
  
  describe 'validations' do
    
    subject do
      FactoryBot.create(:example_alternative)
    end      
    
    it { is_expected.to validate_presence_of(:example_id) }
    
    it { is_expected.to validate_presence_of(:content) }
        
  end
  
  describe 'callbacks' do
    
    context 'after creating' do
      
      it 'updates parent example' do
        
        @example = Example.one
        @example_alternative = FactoryBot.build :example_alternative              
        @example_alternative.example = @example
        @example.update_attribute :updated_at, Date.today - 10.day
        @example_alternative.save!
        
        expect(@example.reload.updated_at.to_date).to eq DateTime.now.utc.to_date
        
      end
      
    end
    
    context 'after updating' do
      
      it 'updates parent example' do
        
        @example = Example.one
        @example_alternative = FactoryBot.create :example_alternative              
        @example_alternative.update_attribute :example, @example
        @example.update_attribute :updated_at, Date.today - 10.day
        @example_alternative.save!
        
        expect(@example.reload.updated_at.to_date).to eq DateTime.now.utc.to_date
        
      end
      
    end
    
    context 'after destroying' do
      
      it 'updates parent example' do
        
        @example = Example.one
        @example_alternative = FactoryBot.create :example_alternative              
        @example_alternative.update_attribute :example, @example
        @example.update_attribute :updated_at, Date.today - 10.day
        @example_alternative.destroy
        
        expect(@example.reload.updated_at.to_date).to eq DateTime.now.utc.to_date
        
      end
      
    end
    
  end
  
end
