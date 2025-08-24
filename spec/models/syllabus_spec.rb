require 'spec_helper'

describe Syllabus do
  
  describe 'validations' do
    
    subject do
      FactoryBot.create(:syllabus)
    end      
    
    it { is_expected.to validate_presence_of(:name) }          
    
  end  
  
  describe 'methods' do
    
    describe 'next' do
      
      before :each do
        Syllabus.create_3
      end
      
      it 'returns the next syllabus' do
        syllabus = Syllabus.first
        expect(syllabus.next).to eq Syllabus.second
      end
      
      it 'returns new if there is no next syllabus' do
        syllabus = Syllabus.last
        expect(syllabus.next).to be_nil
      end
      
    end
    
    describe 'first_active_lesson' do
      
      it 'returns the first active lesson of the syllabus' do
      
        syllabus = Syllabus.one
        
        @lesson1, @lesson2, @lesson3 = 3.Lessons.belongs_to([syllabus])
        
        @lesson1.update_attribute :active, false
        
        @lesson2.move_to_bottom
        
        expect(syllabus.first_active_lesson.id).to be @lesson3.id
        
      end
      
    end
    
  end
  
end
