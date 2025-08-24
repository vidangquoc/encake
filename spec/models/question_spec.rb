require 'spec_helper'

describe Question do
  
  before :each do
    allow(Network::WordPronunciation).to receive(:fetch_for).and_return({possible_pronunciations: [], valid_pronunciation: nil});
  end
  
  describe 'validations' do
    
    subject do
      FactoryBot.create(:question)
    end      
    
    it { is_expected.to validate_presence_of(:content) }
    
    it { is_expected.to validate_presence_of(:point_id) }
    
    it { is_expected.to validate_presence_of(:question_type) }
    
    it "validates 'answer' attribute correctly" do
      
      question = Question.one
      
      question.question_type = 'choosing'
      question.answer = ''
      expect(question.valid?).to be true
      
      question.question_type = 'filling_in'
      question.answer = ''
      expect(question.valid?).to be false
      
      question.question_type = 'filling_in_right_form'
      question.answer = ''
      expect(question.valid?).to be false
      
    end
    
    it "ensures that content of questions of filling_in types contains {...}" do
      
      question = FactoryBot.build :question
      
      ['filling_in', 'filling_in_right_form'].each do |type|
        question.question_type = type
        question.content = "This is invalid"
        expect(question.valid?).to be false
      end
      
      ['filling_in', 'filling_in_right_form'].each do |type|
        question.question_type = type
        question.content = "This {...} is valid"
        expect(question.valid?).to be true
      end
      
    end
    
    it "does not require that content of questions of choosing type contains {...} " do
      
      question = FactoryBot.build :question
      
      question.question_type = 'choosing'
      question.content = "This is content"
      expect(question.valid?).to be true
    
      question.content = "This content contains {...}"
      expect(question.valid?).to be true
      
    end
    
    it {should validate_inclusion_of(:question_type).in_array(Question::TYPES.keys.map(&:to_s))}
  
  end  
  
  describe 'methods' do
              
    describe 'is_right?' do
      
      before :each do
        @question = Question.one
        @right_answer, @wrong_answer = @question.has_2_answers(:assoc)        
        @question.right_answer = @right_answer
        @question.save
      end
      
      it 'returns true if the answer is the right answer of the parent point' do       
        expect(@right_answer.is_right).to be true
      end
      
      it 'returns false if the answer is not the right answer of the parent point' do        
        expect(@wrong_answer.is_right).to be false
      end
      
    end
    
    describe 'is_right=' do
      
      before :each do
        @question = Question.one
        @answer = @question.has_1_answers(:assoc).first
        @answer.is_right = true
        @answer.save
      end
      
      it 'makes the answer to be the right answer of parent question if the passed-in argument is true' do      
        expect(@question.reload.right_answer_id).to be @answer.id
      end
      
      it 'does not turn the right answer to become a wrong answer if the passed-in argument is false' do        
        @answer.is_right = false
        @answer.save
        expect(@question.reload.right_answer_id).to be @answer.id
      end
      
    end
    
    describe 'random_wrong_answer method' do
      
      before :each do
        @question = Question.one
        @question.has_4_answers
      end
      
      it 'returns a wrong answer' do       
        @question.right_answer = @question.answers.sample
        wrong_answer = @question.random_wrong_answer
        expect(wrong_answer.is_right).to be false
      end
      
      it 'returns a wrong answer randomly' do
        indexes = []
        
        20.times do
          wrong_answer = @question.random_wrong_answer
          @question.answers.each_with_index do |answer, index|
            indexes << index if answer.id == wrong_answer.id
          end
        end
        
        expect(indexes.uniq.sort).to eq [0,1,2,3]
      end
      
    end
    
    describe 'update_validity' do
      
      context "question_type is choosing" do
        
        it 'update is_valid attribute to true if question has a right answer' do
          question = Question.one
          question.question_type = 'choosing'
          question.right_answer = Answer.one
          question.is_valid = false
          expect{ question.update_validity }.to change(question, :is_valid).from(false).to(true)
        end
        
        it 'update is_valid attribute to false if question does not have a right answer' do
          question = Question.one(:factory => :valid_question).has_2_answers
          expect(question.is_valid).to eq true
          question.question_type = 'choosing'
          expect{ question.update_validity }.to change(question, :is_valid).from(true).to(false)
        end
        
      end
      
      context "question_type is filling_in for filling_in_right_form" do
        
        it 'update is_valid attribute to true if true' do
          question = Question.one
          question.question_type = 'filling_in'
          question.is_valid = false
          expect{ question.update_validity }.to change(question, :is_valid).from(false).to(true)
        end
        
      end
      
      it "triggers parent point to update it's validity" do
        point = Point.one
        question = Question.one(:factory => :valid_question).belongs_to(point)
        expect_any_instance_of(Point).to receive(:update_validity)
        question.update_validity
      end
      
    end
    
  end
  
  describe 'callbacks' do
    
    context 'after destroy' do
      
      it "tells parent point to update it's validity" do
        point = Point.one
        question1, question2 = point.has_2_questions(:assoc)
        expect_any_instance_of(Point).to receive(:update_validity)
        question1.destroy
      end
      
      it 'updates parent point' do
        
        point = Point.one
        question = FactoryBot.create :question
        question.update_attribute :point, point
        point.update_attribute :updated_at, Date.today - 10.day
        question.destroy
        
        expect(point.reload.updated_at.to_date).to eq DateTime.now.utc.to_date
        
      end
      
    end
    
    context 'right_answer changes' do
      
      it "updates validity" do
        question = Question.one
        answer = Answer.one
        question.right_answer = answer
        expect_any_instance_of(Question).to receive(:update_validity)
        question.save
      end
            
    end
    
    context 'question_type changes' do
      
      it "updates validity" do
        question = FactoryBot.create :question, question_type: 'choosing'
        question.question_type = 'filling_in'
        expect_any_instance_of(Question).to receive(:update_validity)
        question.save
      end
      
    end
    
    context 'after_create' do
      
      it "updates validity" do
        expect_any_instance_of(Question).to receive(:update_validity)
        FactoryBot.build(:question).save!
      end
      
      it 'updates parent point' do
        
        point = Point.one
        question = FactoryBot.build :question
        question.point = point
        point.update_attribute :updated_at, Date.today - 10.day
        question.save!
        
        expect(point.reload.updated_at.to_date).to eq DateTime.now.utc.to_date
        
      end
      
    end
    
    context 'after updating' do
      
      it 'updates parent point' do
        
        point = Point.one
        question = FactoryBot.create :question
        question.update_attribute :point, point
        point.update_attribute :updated_at, Date.today - 10.day
        question.save!
        
        expect(point.reload.updated_at.to_date).to eq DateTime.now.utc.to_date
        
      end
      
    end
    
  end
  
end
