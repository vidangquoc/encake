require 'spec_helper'

describe Answer do
  
  describe 'validations' do
    
    subject do
      FactoryBot.create(:answer)
    end      
    
    it { is_expected.to validate_presence_of(:content) }      
    
    it { is_expected.to validate_presence_of(:question_id) }
       
  end
  
  
  describe 'methods' do
    
    describe 'is_right' do
      
      before :each do
        @question = Question.one
        @right_answer, @not_right_answer = @question.has_2_answers(:assoc)        
        @question.right_answer = @right_answer
        @question.save
      end
      
      it 'returns true if the answer is the right answer of the parent point' do       
        expect(@right_answer.is_right).to be true
      end
      
      it 'returns false if the answer is not the right answer of the parent point' do        
        expect(@not_right_answer.is_right).to be false
      end
      
    end
    
    describe 'is_right=' do
          
      before :each do
        @question = Question.one
        @answer = FactoryBot.build :answer
        @answer.question = @question
      end
      
      it 'makes the answer to be the right answer of parent question if the passed-in argument is true' do
                 
        @answer.is_right = true
        @answer.save
        
        expect(@question.reload.right_answer_id).to be @answer.id
        
      end
      
      it 'does not makes the answer to be the right answer of parent question if the passed-in argument is false' do
               
        @answer.is_right = false
        @answer.save
        
        expect(@question.reload.right_answer_id).not_to be @answer.id
        
      end
      
      it 'does not turn the right answer to become a wrong answer if the passed-in argument is false' do
        
        @answer.is_right = true
        @answer.save
        expect(@question.reload.right_answer_id).to be @answer.id
        
        @answer.is_right = false
        @answer.save
        expect(@question.reload.right_answer_id).to be @answer.id
        
      end
  
    end
    
  end
  
  
  describe 'callbacks' do
    
    context 'after destroy' do
      
      it "tells parent question to update it's validity" do
        question = Question.one
        answer1, answer2 = question.has_2_answers(:assoc)
        expect_any_instance_of(Question).to receive(:update_validity)
        answer1.destroy
      end
      
    end
    
  end
    
end
