require 'spec_helper'

describe ReviewSkill do
  
  describe "methods:" do
    
    before :each do
      @review_skill = FactoryBot.create :review_skill, skill: 0
    end
    
    describe 'update_effectively_reviewed_times:' do
                 
      context 'reminded_times is 0' do
          
        it 'increases effectively_reviewed_times by 1' do
          reminded_times = 0
          expect { @review_skill.update_effectively_reviewed_times(reminded_times) }.to change(@review_skill, :effectively_reviewed_times).by(1)
        end
        
      end
      
      context 'reminded_times is 1' do
        
        before :each do
          @reminded_times = 1
        end
        
        it 'sets effectively_reviewed_times to 1 if current effectively_reviewed_times is 0' do
          @review_skill.effectively_reviewed_times = 0
          expect { @review_skill.update_effectively_reviewed_times( @reminded_times ) }.to change(@review_skill, :effectively_reviewed_times).to(1)
        end
        
        it 'keeps effectively_reviewed_times unchange if current effectively_reviewed_times is 1 or 2' do
          (1..2).each do |effectively_reviewed_times|
            @review_skill.effectively_reviewed_times = effectively_reviewed_times
            expect { @review_skill.update_effectively_reviewed_times( @reminded_times ) }.not_to change(@review_skill, :effectively_reviewed_times)
          end
        end
        
        it "sets effectively_reviewed_times to 2 if current effectively_reviewed_times is greater than 2" do
          (3..10).each do |effectively_reviewed_times|            
            @review_skill.effectively_reviewed_times = effectively_reviewed_times
            expect { @review_skill.update_effectively_reviewed_times( @reminded_times ) }.to change(@review_skill, :effectively_reviewed_times).to(2)            
          end
        end
        
      end
      
      context "reminded_times is greater than 1" do
        it 'sets effectively_reviewed_times to 1' do
          (2..10).each do |reminded_times|            
            @review_skill.effectively_reviewed_times = 10            
            expect { @review_skill.update_effectively_reviewed_times( reminded_times ) }.to change(@review_skill, :effectively_reviewed_times).to(1)                       
          end
        end
      end
      
      context 'last_reviewed_date is today' do
        it 'keeps effectively_reviewed_times unchange' do
          @review_skill.last_reviewed_date = Date.today
          (0..10).each do |reminded_times| 
            expect { @review_skill.update_effectively_reviewed_times(reminded_times) }.not_to change(@review_skill, :effectively_reviewed_times)
          end
        end
      end
      
      it 'returns the change of effective review times' do
        @review_skill.effectively_reviewed_times = 5
        expect(@review_skill.update_effectively_reviewed_times(3)).to equal(-4)
      end
      
      it "sets the number of effectively reviewed times for the skills correctly if is_mastered parameter is passed" do
        is_mastered = true
        @review_skill.update_effectively_reviewed_times(0, is_mastered)
        expect(@review_skill.effectively_reviewed_times).to eq 10
      end
      
      it "sets the number of effectively reviewed times for the skills correctly if first_learnt_without_reminding parameter is passed" do
        first_learnt_without_reminding = true
        @review_skill.update_effectively_reviewed_times(0, false, first_learnt_without_reminding)
        expect(@review_skill.effectively_reviewed_times).to eq 3
      end
      
    end
    
    describe 'update_reminded_times' do
      
      it 'update reminded_times correctly' do
        (1...10).each do |reminded_times|          
          expect { @review_skill.update_reminded_times(reminded_times) }.to change(@review_skill, :reminded_times).by(reminded_times)
        end
      end
      
    end
    
    describe 'update_review_due_date' do
      
      it 'updates review_due_date for spelling skill according to effectively_reviewed_times' do
        
        #word skill
        spacing_factor = ReviewSkill::SPACING_FACTORS.fetch(:interpret)
        
        data = {
          1 => 5,
          2 => spacing_factor**(2),
        }
        
        data.each_pair do |effectively_reviewed_times, review_due_date_from_today|
          review_skill = ReviewSkill.new skill: ReviewSkill::SKILLS.fetch(:interpret) , effectively_reviewed_times: effectively_reviewed_times
          expect {review_skill.update_review_due_date}.to change(review_skill, :review_due_date).to(Date.today + review_due_date_from_today.days)         
        end
        
        #effectively reviewed times greater than or equal to 3
        [3, 4, 5].each do |effectively_reviewed_times|
          review_skill = ReviewSkill.new skill: ReviewSkill::SKILLS.fetch(:interpret) , effectively_reviewed_times: effectively_reviewed_times
          review_skill.update_review_due_date
          expect(review_skill.review_due_date).to be > 99.years.from_now
        end
        
        
        #other skills  
        ReviewSkill::SKILLS.except(:interpret).keys.each do |skill_symbol|
          
          spacing_factor = ReviewSkill::SPACING_FACTORS.fetch(skill_symbol)
          
          data = {
            1 => 5,
            2 => spacing_factor**(2),
            3 => spacing_factor**(3),
            4 => spacing_factor**(4),
            5 => spacing_factor**(5),
          }
          
          data.each_pair do |effectively_reviewed_times, review_due_date_from_today|
            review_skill = ReviewSkill.new skill: ReviewSkill::SKILLS.fetch(skill_symbol) , effectively_reviewed_times: effectively_reviewed_times
            expect {review_skill.update_review_due_date}.to change(review_skill, :review_due_date).to(Date.today + review_due_date_from_today.days)         
          end
          
        end
        
      end

    end
    
    describe 'randomize_review_due_date' do
      
      it "adds a randomness to review due date" do
        
        due_date = Date.today + 10.days
        date_diffs = []
        
        100.times do
          review_skill = ReviewSkill.new review_due_date: due_date  
          review_skill.randomize_review_due_date
          date_diffs.push (review_skill.review_due_date - due_date).to_i
        end
        
        expect(date_diffs.uniq.sort).to eq [-1, 0, 1]
        
      end
      
      it "does not cause review due date to be less than tomorrow" do
        
        due_date = today.tomorrow
        date_diffs = []
        
        100.times do
          review_skill = ReviewSkill.new review_due_date: due_date  
          review_skill.randomize_review_due_date
          date_diffs.push (review_skill.review_due_date - due_date).to_i
        end
        
        expect(date_diffs.uniq.sort).to eq [0, 1]
        
      end
      
    end
    
    describe 'increase_reviewed_times' do
      
      it 'increases reviewed_times by 1' do        
        expect { @review_skill.increase_reviewed_times }.to change(@review_skill, :reviewed_times).by(1)        
      end
      
    end
    
    describe 'update_last_reviewed_date' do
      
      it 'sets last_reviewed_date to current day' do                
        expect { @review_skill.update_last_reviewed_date }.to change(@review_skill, :last_reviewed_date).to(Date.today)                    
      end
          
    end
        
    describe 'process_review' do
      
      it 'calls the right methods' do
        expect(@review_skill).to receive(:update_effectively_reviewed_times).with(0, true, true)
        expect(@review_skill).to receive :update_review_due_date
        expect(@review_skill).to receive :randomize_review_due_date
        expect(@review_skill).to receive :increase_reviewed_times
        expect(@review_skill).to receive :update_last_reviewed_date 
        expect(@review_skill).to receive(:update_reminded_times).with(0)
        @review_skill.process_review(0, true, true)
      end
      
      it "returns the change of score" do
        
        @review_skill.belongs_to(Review.one, :assoc).belongs_to(Point.one)
        
        @review_skill.update_attribute :effectively_reviewed_times, 1
        expect(@review_skill.process_review(0)).to be 1
        
        @review_skill.update_attributes effectively_reviewed_times: 5, last_reviewed_date: Date.today - 2.days
        expect(@review_skill.process_review(3)).to equal(-4)
        
        @review_skill.update_attributes effectively_reviewed_times: 11, last_reviewed_date: Date.today - 2.days
        expect(@review_skill.process_review(0)).to equal(0)
        
        @review_skill.update_attributes effectively_reviewed_times: 10, last_reviewed_date: Date.today - 2.days
        expect(@review_skill.process_review(0)).to equal(0)
        
        @review_skill.update_attributes effectively_reviewed_times: 11, last_reviewed_date: Date.today - 2.days
        expect(@review_skill.process_review(3)).to equal(-9)
        
      end
      
    end
    
    #describe "Class#first_built_grammar_skil_for_point" do
    #  
    #  it "returns the first grammar skill according to point type" do
    #    
    #    point = Point.one
    #    
    #    point.update_attributes is_private: true
    #    
    #    expect(ReviewSkill.first_built_grammar_skills_for_point(point)).to be nil
    #    
    #    point.update_attributes is_private: false, is_valid: true
    #    
    #    expect(ReviewSkill.first_built_grammar_skills_for_point(point)).to be ReviewSkill::SKILLS.fetch(:translating)
    #    
    #    point.update_attributes is_private: false, is_valid: false, is_supporting: true
    #    
    #    expect(ReviewSkill.first_built_grammar_skills_for_point(point)).to be nil
    #    
    #  end
    #  
    #end
    
    describe "Class#build_skills_for_review" do
      
      before :each do
        
        @point = Point.one
        @review = Review.one.belongs_to @point
        
      end
      
      it 'builds skills correctly for supporting points' do
        
        @point.update_attributes is_private: false, is_valid: false, is_supporting: true
        
        skills = ReviewSkill.build_skills_for_review(@review)
        
        expected = {
          interpret: true,
          grammar: false,
          verbal: false,
        }
        
        expected.each_pair do |skill_symbol, built|
          expect(skills.any?{|skill| skill.skill == ReviewSkill::SKILLS.fetch(skill_symbol)}).to be built  
        end
        
      end
      
      it 'builds skills correctly for valid points' do
        
        @point.update_attributes is_valid: true, is_supporting: true
        
        skills = ReviewSkill.build_skills_for_review(@review)
        
        expected = {
          interpret: true,
          grammar: true,
          verbal: true,
        }
        
        expected.each_pair do |skill_symbol, built|
          expect(skills.any?{|skill| skill.skill == ReviewSkill::SKILLS.fetch(skill_symbol)}).to be built  
        end
        
      end
      
      it 'builds skills correctly for private points' do
        
        @point.update_attributes is_valid: false, is_supporting: false, is_private: true
        
        skills = ReviewSkill.build_skills_for_review(@review)
        
        expected = {
          interpret: true,
          grammar: false,
          verbal: true,
        }
        
        expected.each_pair do |skill_symbol, built|
          expect(skills.any?{|skill| skill.skill == ReviewSkill::SKILLS.fetch(skill_symbol)}).to be built  
        end  
        
      end
      
      it "sets the number of effectively reviewed times for the skills correctly if mastered_skills parameter is passed" do
        
        @point.update_attributes is_valid: true
        
        skills = ReviewSkill.build_skills_for_review(@review, [:interpret])
        
        expect(skills.find{ |skill| skill.skill == ReviewSkill::SKILLS.fetch(:interpret)}.effectively_reviewed_times).to be 10
        
      end
      
      it "sets the number of effectively reviewed times for the skills correctly if no_reminded_skills parameter is passed" do
        
        @point.update_attributes is_valid: true
        
        skills = ReviewSkill.build_skills_for_review(@review, [], [:interpret])
        
        expect(skills.find{ |skill| skill.skill == ReviewSkill::SKILLS.fetch(:interpret)}.effectively_reviewed_times).to be 3
        
      end
      
    end
    
  end
  
end
