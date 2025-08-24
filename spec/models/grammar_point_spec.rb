require 'spec_helper'

describe GrammarPoint do
  
  describe "Validations" do
    
    subject {FactoryBot.build :grammar_point}
    
    it 'should create a new instance given valid attributes' do
      FactoryBot.create(:grammar_point)
    end
    
    it { is_expected.to validate_presence_of(:lesson_id) }
    
    it { is_expected.to validate_presence_of(:content) }
    
  end
  
  describe 'methods' do
  
    describe 'the_grammar_point_with_the_less_examples' do
      
      before :each do
              
        @grammar_point_with_10_examples = GrammarPoint.one.has_10_examples
        @grammar_point_with_5_examples = GrammarPoint.one.has_5_examples
        @grammar_point_with_1_examples = GrammarPoint.one.has_1_examples
               
      end
           
      it 'gets the grammar point which has the less examples' do                   
        expect(GrammarPoint.the_grammar_point_with_the_less_examples.id).to be @grammar_point_with_1_examples.id
      end
      
      it 'excludes the passed-in grammar point ids' do        
        expect(GrammarPoint.the_grammar_point_with_the_less_examples([@grammar_point_with_1_examples.id, @grammar_point_with_5_examples]).id).to be @grammar_point_with_10_examples.id
      end
           
      it 'returns nil if no grammar point is found' do
        GrammarPoint.destroy_all
        expect(GrammarPoint.the_grammar_point_with_the_less_examples).to be nil
      end
      
    end
   
  end
  
  describe 'callbacks' do
    
    describe 'after updating' do
      
      it 'touch child examples' do
        
        grammar_point = GrammarPoint.one
        example = Example.one.belongs_to grammar_point
        example.update_attribute :updated_at, today - 10.days
        
        grammar_point.examples.reload
        
        grammar_point.update_attribute :updated_at, today
        
        expect(example.reload.updated_at.localtime.to_date).to eq today
        
      end
      
    end
        
  end
  
end
