require 'rails_helper'

RSpec.describe Opportunity, type: :model do
  
  describe "methods" do
    
    describe "ignore" do
      
      it "changes 'is_taken' attribute to true" do
        
        opportunity = FactoryBot.create :opportunity, is_taken: false
        
        opportunity.ignore
        
        expect(opportunity.reload.is_taken).to be true
        
      end
      
    end
    
    describe 'calculate_possibility' do
      
      before :each do
        create_badge_types
        @user = User.one
        @opportunity = FactoryBot.create :opportunity, user_id: @user.id,  badge_type: @badge_type
      end
      
      context "passed-in number_of_used_lucky_starts does not exceed the number of lucky start the user has" do
      
        context "passed-in number_of_used_lucky_starts does not exceed (max_opportunity_possibility - min_opportunity_possibility)" do
          
          it "uses passed-in number_of_used_lucky_stars" do
            
            max_usable_lucky_stars = Constants.max_opportunity_possibility - Constants.min_opportunity_possibility
            
            number_of_used_lucky_stars = max_usable_lucky_stars - 10
            
            number_of_lucky_stars_user_has = number_of_used_lucky_stars + 5
            
            Badge.reward_lucky_stars_to_user(@user.id, number_of_lucky_stars_user_has)
            
            result = @opportunity.calculate_possibility(number_of_used_lucky_stars)
            
            expect( result[:possibility] ).to eq (Constants.min_opportunity_possibility + number_of_used_lucky_stars)
            expect( result[:number_of_used_lucky_stars] ).to eq number_of_used_lucky_stars
            
          end
        
        end
      
        context "passed-in number_of_used_lucky_starts exceeds (max_opportunity_possibility - min_opportunity_possibility)" do
          
          it "uses passed-in (max_opportunity_possibility - min_opportunity_possibility)" do
            
            max_usable_lucky_stars = Constants.max_opportunity_possibility - Constants.min_opportunity_possibility
            
            number_of_used_lucky_stars = max_usable_lucky_stars + 10
            
            number_of_lucky_stars_user_has = number_of_used_lucky_stars + 5
            
            Badge.reward_lucky_stars_to_user(@user.id, number_of_lucky_stars_user_has)
            
            result = @opportunity.calculate_possibility(number_of_used_lucky_stars)
            
            expect( result[:possibility] ).to eq Constants.max_opportunity_possibility
            expect( result[:number_of_used_lucky_stars] ).to eq max_usable_lucky_stars
            
          end
        
        end
      
      end
      
      context "passed-in number_of_used_lucky_starts exceeds the number of lucky start the user has" do
      
        context "the number of lucky start the user has does not exceed (max_opportunity_possibility - min_opportunity_possibility)" do
        
          it "uses the number of lucky start the user has" do
            
            number_of_lucky_stars_user_has = 10
            
            number_of_used_lucky_stars = 50
            
            Badge.reward_lucky_stars_to_user(@user.id, number_of_lucky_stars_user_has)
            
            result = @opportunity.calculate_possibility(number_of_used_lucky_stars)
            
            expect( result[:possibility] ).to eq (Constants.min_opportunity_possibility + number_of_lucky_stars_user_has)
            expect( result[:number_of_used_lucky_stars] ).to eq number_of_lucky_stars_user_has
            
          end
        
        end
        
        context "the number of lucky start the user has exceeds (max_opportunity_possibility - min_opportunity_possibility)" do
        
          it "uses (max_opportunity_possibility - min_opportunity_possibility)" do
            
            max_usable_lucky_stars = Constants.max_opportunity_possibility - Constants.min_opportunity_possibility
            
            number_of_lucky_stars_user_has = max_usable_lucky_stars + 10
            
            number_of_used_lucky_stars = number_of_lucky_stars_user_has + 10
            
            Badge.reward_lucky_stars_to_user(@user.id, number_of_lucky_stars_user_has)
            
            result = @opportunity.calculate_possibility(number_of_used_lucky_stars)
            
            expect( result[:possibility] ).to eq Constants.max_opportunity_possibility
            expect( result[:number_of_used_lucky_stars] ).to eq max_usable_lucky_stars
            
          end
        
        end
        
      end
      
    end
    
    describe 'take' do
      
      before :each do
        create_badge_types
        @user = User.one
        @opportunity = FactoryBot.create :opportunity, user_id: @user.id
      end
      
      it 'calculates possibility correctly' do
        
        number_of_used_lucky_stars = 20
        
        expect(@opportunity).to receive(:calculate_possibility).with(number_of_used_lucky_stars).and_return({possibility: 20, number_of_used_lucky_stars: 10})
        
        @opportunity.take(number_of_used_lucky_stars)
        
      end
      
      it 'uses Class#toss method to decide if the user win or lose the opportunity' do
        
        expect(Opportunity).to receive(:toss)
        
        @opportunity.take(10)
        
      end
      
      it 'destroys the opportunity' do
        
        @opportunity.take(10)
        
        expect(Opportunity.find_by(id: @opportunity.id) ).to be nil
               
      end
      
      it "takes number of used lucky stars from the user" do
                
        Badge.reward_lucky_stars_to_user(@user.id, 30)
        
        number_of_used_lucky_stars = 20
        
        @opportunity.take(number_of_used_lucky_stars)
        
        expect(Badge.count_lucky_stars_for_user(@user.id) ).to eq (30 - 20)
        
      end
      
      context 'the user wins' do
        before :each do
          allow(Opportunity).to receive(:toss).and_return(true)
        end
        it "returns true" do
          expect( @opportunity.take(0) ).to be true
        end
        it 'create a GotBadge event' do
          @opportunity.take(0)
          event = UserGotBadgeEvent.find_by(user_id: @opportunity.id)
          expect(event).not_to be nil
          expect(event.data[:badge_type_id]).to eq @opportunity.badge_type.id
        end
      end
      
      context 'the user loses' do
        before :each do
          allow(Opportunity).to receive(:toss).and_return(false)
        end
        it "returns false" do
          expect( @opportunity.take(0) ).to be false
        end
        it 'does not create a GotBadge event' do
          @opportunity.take(0)
          event = UserGotBadgeEvent.find_by(user_id: @opportunity.id)
          expect(event).to be nil
        end
      end
      
      context "the opportunity is of 'diligent' type" do
        
        before :each do
          @badge_type = find_badge_type('diligent', 3)
          @review_summary = FactoryBot.create :review_summary, user_id: @user.id, continuous_reviewing_days: @badge_type.number_of_efforts_to_get + 10, number_of_reviewed_items_today: 15
          @opportunity.update_attributes badge_type: @badge_type
        end
        
        it "updates 'continuous_reviewing_days' attribute of review summary" do
          @opportunity.take(10)
          @review_summary.reload
          expect(@review_summary.continuous_reviewing_days).to eq 10
          expect(@review_summary.number_of_reviewed_items_today).to eq 15
        end
        
        it "rewards the user a badge with correct badge type if the user wins" do
          
          allow(Opportunity).to receive(:toss).and_return(true)
          
          expect(Badge).to receive(:reward_to_user).with(@user.id, @badge_type.id)
          
          @opportunity.take(10)
          
        end
        
        it "does not reward the user a badge if the user loses" do
          
          allow(Opportunity).to receive(:toss).and_return(false)
          
          expect(Badge).not_to receive(:reward_to_user)
          
          @opportunity.take(10)
          
        end
        
      end
      
      context "the opportunity is of 'warrior' type" do
        
        before :each do
          @badge_type = find_badge_type('warrior', 3)
          @review_summary = FactoryBot.create :review_summary, user_id: @user.id, number_of_reviewed_items_today: @badge_type.number_of_efforts_to_get + 10, continuous_reviewing_days: 15
          @opportunity.update_attributes badge_type: @badge_type
        end
        
        it "updates 'number_of_reviewed_items_today' attribute of review summary" do
          @opportunity.take(10)
          @review_summary.reload
          expect(@review_summary.number_of_reviewed_items_today).to eq 10
          expect(@review_summary.continuous_reviewing_days).to eq 15
        end
        
        it "rewards the user a badge with correct badge type if the user wins" do
          
          allow(Opportunity).to receive(:toss).and_return(true)
          
          expect(Badge).to receive(:reward_to_user).with(@user.id, @badge_type.id)
          
          @opportunity.take(10)
          
        end
        
        it "does not reward the user a badge if the user loses" do
          
          allow(Opportunity).to receive(:toss).and_return(false)
          
          expect(Badge).not_to receive(:reward_to_user)
          
          @opportunity.take(10)
          
        end
        
      end
      
    end
    
    describe 'Class#toss' do
      
      it "returns 'win' according to passed-in possibility" do
     
        possibility = 80
        
        number_of_wins = 0
        
        number_of_tosses = 1_000_000
        
        number_of_tosses.times do
          number_of_wins += 1 if Opportunity.toss(possibility)          
        end
        
        win_percent = (number_of_wins.fdiv(number_of_tosses)*100).round
        
        expect(win_percent).to eq possibility
        
      end
      
    end
    
  end
  
end
