require 'rails_helper'

RSpec.describe Badge, type: :model do
  
  describe "METHODS" do
    
    describe "Class#reward_badge_to_user" do
      
      context "no badge record of the given badge type exists for the given user" do
        
        it "creates a new record of the given badge type for the given user" do
          
          user_id = 1
          
          badge_type_id = 2
          
          Badge.reward_to_user(user_id , badge_type_id)
          
          badge = Badge.find_by(user_id: user_id, badge_type_id: badge_type_id)
          
          expect(badge).not_to be nil
          expect(badge.number_of_badges).to be 1
          
        end
        
      end
      
      context "a badge record of the given badge type exists for the given user" do
        
        it "increases 'number_of_badges' attribute of the record by one" do
          
          user_id = 1
          
          badge_type_id = 2
          
          badge = FactoryBot.create :badge, user_id: user_id, badge_type_id: badge_type_id, number_of_badges: 1
          
          Badge.reward_to_user(user_id , badge_type_id)
          
          expect(Badge.count).to be 1
          expect(badge.reload.number_of_badges).to be 2
          
        end
        
      end
      
    end
    
    describe "Class#reward_lucky_star_to_user" do
      
      before :each do
        create_badge_types
        @lucky_start_badge_type = BadgeType.find_by(badge_type: 'lucky_star')
      end
      
      context "no badge record of 'lucky_star' badge type exists for the given user" do
        
        it "creates a new record of 'lucky_star' badge type for the given user" do
          
          user_id = 1
          
          Badge.reward_lucky_stars_to_user(user_id, 5)
          
          badge = Badge.find_by(user_id: user_id, badge_type_id: @lucky_start_badge_type.id)
          
          expect(badge).not_to be nil
          expect(badge.number_of_badges).to be 5
          
        end
        
      end
      
      context "a badge record of 'lucky_star' badge type exists for the given user" do
        
        it "increases 'number_of_badges' attribute of the record by one" do
          
          user_id = 1
          
          badge = FactoryBot.create :badge, user_id: user_id, badge_type_id: @lucky_start_badge_type.id, number_of_badges: 5
          
          Badge.reward_lucky_stars_to_user(user_id, 5)
          
          expect(Badge.count).to be 1
          expect(badge.reload.number_of_badges).to be 10
          
        end
        
      end
      
    end
    
    describe "Class#count_lucky_stars_for_user" do
      
      before :each do
        create_badge_types
        @lucky_start_badge_type = BadgeType.find_by(badge_type: 'lucky_star')
      end
      
      context "no badge record of 'lucky_star' badge type exists for the given user" do
        
        it "returns 0" do
          
          user_id = 1
          
          expect(Badge.count_lucky_stars_for_user(user_id)).to be 0
          
        end
        
      end
      
      context "a badge record of 'lucky_star' badge type exists for the given user" do
        
        it "returns 'number_of_badges' attribute of the record" do
          
          user_id = 1
          
          badge = FactoryBot.create :badge, user_id: user_id, badge_type_id: @lucky_start_badge_type.id, number_of_badges: 10
          
          expect(Badge.count_lucky_stars_for_user(user_id)).to be 10
          
        end
        
      end
      
    end
    
    describe "Class#take_luck_stars_from_user" do
      
      it "takes lucky stars from user" do
        
        create_badge_types
        
        user_id = 1
        
        Badge.reward_lucky_stars_to_user(user_id, 10)
        
        Badge.take_luck_stars_from_user(user_id, 5)
        
        expect(Badge.count_lucky_stars_for_user(user_id)).to eq 5
        
      end
      
    end
    
    describe 'Class#toss_lucky_stars_to_user' do
      
      before :each do
        create_badge_types
        @user = User.one
      end
      
      it 'calls Opportunity#toss to decide if the user is rewarded lucky stars with the possibility of 33%' do
        expect(Opportunity).to receive(:toss).with(33)
        Badge.toss_lucky_stars_to_user(@user.id)
      end
      
      it "calls Badge#rand_number_of_lucky_stars to specify the number of rewarded lucky stars" do
        allow(Opportunity).to receive(:toss).and_return(true)
        expect(Badge).to receive(:rand_number_of_lucky_stars)
        Badge.toss_lucky_stars_to_user(@user.id)
      end
      
      it "saves and returns the number of rewarded lucky stars" do
        allow(Opportunity).to receive(:toss).and_return(true)
        allow(Badge).to receive(:rand_number_of_lucky_stars).and_return(5)
        expect( Badge.toss_lucky_stars_to_user(@user.id) ).to eq 5
        expect( Badge.count_lucky_stars_for_user(@user.id) ).to be 5
      end
      
      it 'rewards the user 4.5 lucky stars each rewarded times on avarage' do
        
        rewarded_times = 0
        
        100.times do
          number_of_rewarded_lucky_stars = Badge.toss_lucky_stars_to_user(@user.id)
          rewarded_times += 1 if number_of_rewarded_lucky_stars > 0
        end
        
        expect( Badge.count_lucky_stars_for_user(@user.id).fdiv(rewarded_times) ).to be_between(4.1, 4.9)
        
      end
      
    end
    
    describe "rand_number_of_lucky_stars" do
      
      it 'returns 4.5 on avarage' do
        
        total = 0
        times = 1000
        
        times.times do
          total += Badge.rand_number_of_lucky_stars
        end
        
        expect( total.fdiv(times) ).to be_between(4.3, 4.7)
        
      end
      
    end
  
  end
  
end
