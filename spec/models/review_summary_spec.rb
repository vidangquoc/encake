require 'rails_helper'

RSpec.describe ReviewSummary, type: :model do
  
  before :each do
    create_badge_types
    @user = User.one
  end
  
  #METHODS
  describe 'Class#update_review_summary_for_user' do
    
    context "there is no existing summary record for the user" do
      
      it "creates new summary record for the user with correct data" do
        
        ReviewSummary.update_review_summary_for_user(@user.id, 10)
        
        review_summary = ReviewSummary.first
        expect(review_summary).not_to be nil
        expect(review_summary.user_id).to eq @user.id
        expect(review_summary.date).to eq today
        expect(review_summary.continuous_reviewing_days).to eq 1
        expect(review_summary.number_of_reviewed_items_today).to eq 10
        
      end
      
    end
    
    context "there is an existing summary record for the user" do
      
      context "summary data was updated sooner than or equal to 2 days ago" do
        
        before :each do        
          ReviewSummary.create user_id: @user.id, date: today - 2.days , continuous_reviewing_days: 10, number_of_reviewed_items_today: 50
        end
        
        it "updates the existing record for the user with correct data" do
          
          ReviewSummary.update_review_summary_for_user(@user.id, 10)
          
          expect(ReviewSummary.count).to eq 1
          
          review_summary = ReviewSummary.first
          
          expect(review_summary.user_id).to eq @user.id
          expect(review_summary.date).to eq today
          expect(review_summary.continuous_reviewing_days).to eq 1
          expect(review_summary.number_of_reviewed_items_today).to eq 10
          
        end
        
        it "clears obsolete 'diligent badge' opportunities" do
          
          FactoryBot.create :opportunity, user_id: @user.id, badge_type_id: BadgeType.where(badge_type: 'diligent').first.id
          
          ReviewSummary.update_review_summary_for_user(@user.id, 10)
          
          expect(Opportunity.count).to be 0
          
        end
        
        it "clears obsolete 'warrior badge' opportunities" do
          
          FactoryBot.create :opportunity, user_id: @user.id, badge_type_id: BadgeType.where(badge_type: 'warrior').first.id
          
          ReviewSummary.update_review_summary_for_user(@user.id, 10)
          
          expect(Opportunity.count).to be 0
          
        end
      
      end
    
      context "summary data was updated yesterday" do
        
        before :each do
          ReviewSummary.create user_id: @user.id, date: today - 1.days , continuous_reviewing_days: 10, number_of_reviewed_items_today: 50
        end
      
        it "updates the existing record for the user with correct data" do
          
          ReviewSummary.update_review_summary_for_user(@user.id, 10)
          
          expect(ReviewSummary.count).to eq 1
          
          review_summary = ReviewSummary.first
          
          expect(review_summary.user_id).to eq @user.id
          expect(review_summary.date).to eq today
          expect(review_summary.continuous_reviewing_days).to eq 11
          expect(review_summary.number_of_reviewed_items_today).to eq 10
          
        end
        
        it "clears obsolete 'warrior badge' opportunities" do
          
          FactoryBot.create :opportunity, user_id: @user.id, badge_type_id: BadgeType.where(badge_type: 'warrior').first.id
          
          ReviewSummary.update_review_summary_for_user(@user.id, 10)
          
          expect(Opportunity.count).to be 0
          
        end
      
      end
    
      context "summary data was updated today" do
        
        it "updates the existing record for the user with correct data" do
          
          ReviewSummary.create user_id: @user.id, date: today, continuous_reviewing_days: 10, number_of_reviewed_items_today: 50
          
          ReviewSummary.update_review_summary_for_user(@user.id, 10)
          
          expect(ReviewSummary.count).to eq 1
          
          review_summary = ReviewSummary.first
          
          expect(review_summary.user_id).to eq @user.id
          expect(review_summary.date).to eq today
          expect(review_summary.continuous_reviewing_days).to eq 10
          expect(review_summary.number_of_reviewed_items_today).to eq 60
          
        end
        
        it "detect 'diligent badge' opportunities" do

          @badge_type = BadgeType.where(badge_type: 'diligent').order("number_of_efforts_to_get ASC").first(3).last
          @review_summary = ReviewSummary.create! user_id: @user.id, date: today, continuous_reviewing_days: @badge_type.number_of_efforts_to_get, number_of_reviewed_items_today: 1
          
          opportunity = ReviewSummary.update_review_summary_for_user(@user.id, 10)
        
          expect(opportunity).not_to be nil
          expect(opportunity.user_id).to be @user.id
          expect(opportunity.badge_type_id).to eq @badge_type.id
          expect(opportunity.is_taken).to be false
          
        end
        
        it "detect 'warrior badge' opportunities" do

          @badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").first(3).last
          FactoryBot.create :review_summary, user_id: @user.id, date: today, continuous_reviewing_days: 1, number_of_reviewed_items_today: @badge_type.number_of_efforts_to_get
      
          opportunity = ReviewSummary.update_review_summary_for_user(@user.id, 1)
        
          expect(opportunity).not_to be nil
          expect(opportunity.user_id).to be @user.id
          expect(opportunity.badge_type_id).to eq @badge_type.id
          expect(opportunity.is_taken).to be false
          
        end
      
      end
      
    end
    
    context "there is an existing opportunity" do
      
      before :each do
        @existing_opportunity = Opportunity.create! user_id: @user.id, badge_type: find_badge_type('diligent', 2) , is_taken: false
        
      end
      
      context "no new opportunity is detected" do
        
        before :each do
          FactoryBot.create :review_summary, user_id: @user.id, date: today, continuous_reviewing_days: 1, number_of_reviewed_items_today: 1
        end
        
        context 'the existing opportunity is untaken' do
          
          it 'returns the untaken opportunity' do
            
            opportunity = ReviewSummary.update_review_summary_for_user(@user.id, 1)
            
            expect(opportunity.id).not_to be nil
            expect(opportunity.id).to eq @existing_opportunity.id
            
          end
        
          it 'does not return untaken opportunities of other users' do
            
            @existing_opportunity.update_attributes user_id: @user.id + 1
            opportunity = ReviewSummary.update_review_summary_for_user(@user.id, 1)
            
            expect(opportunity).to be nil
            
          end
          
        end
        
        context 'the existing opportunity is taken' do
          
          it 'returns nil' do

            @existing_opportunity.update_attributes is_taken: true
            opportunity = ReviewSummary.update_review_summary_for_user(@user.id, 1)
            
            expect(opportunity).to be nil
            
          end
          
        end
        
      end
      
      context "a new opportunity is detected" do
        
        it "returns the newly detected opportunity" do
          
          badge_type = find_badge_type('warrior', 3)
          FactoryBot.create :review_summary, user_id: @user.id, date: today, continuous_reviewing_days: 1, number_of_reviewed_items_today: badge_type.number_of_efforts_to_get
      
          opportunity = ReviewSummary.update_review_summary_for_user(@user.id, 1)
          expect(opportunity).not_to be nil
          expect(opportunity.id).not_to eq @existing_opportunity.id
          
        end
        
      end
      
    end
    
  end
  
  describe "detect_opportunities" do
    
    describe "detects 'diligent badge' opportunity" do
      
      before :each do
        @badge_type = BadgeType.where(badge_type: 'diligent').order("number_of_efforts_to_get ASC").first(3).last
        @review_summary = ReviewSummary.create! user_id: @user.id, date: today, continuous_reviewing_days: @badge_type.number_of_efforts_to_get
      end
      
      it "creates and returns an opportunity for the right badge type" do
        
        opportunity = @review_summary.detect_opportunities
        
        expect(opportunity).not_to be nil
        expect(opportunity.user_id).to be @user.id
        expect(opportunity.badge_type_id).to eq @badge_type.id
        expect(opportunity.is_taken).to be false
        
      end
      
      it "does not create an opportunity and return nil if an opportunity of the same type and sub type exists" do
        
        Opportunity.create! user_id: @user.id, badge_type_id: @badge_type.id
        
        opportunity = @review_summary.detect_opportunities
        
        expect(Opportunity.count).to eq 1
        expect(opportunity).to be nil
        
      end
      
      it "removes exisiting opportunities for lower sub types of the same type" do
        
        Opportunity.create! user_id: @user.id, badge_type_id: BadgeType.where(badge_type: 'diligent').order("number_of_efforts_to_get ASC").first(2).last.id
        
        opportunity = @review_summary.detect_opportunities
        
        expect(opportunity.badge_type_id).to eq @badge_type.id
        expect(Opportunity.count).to eq 1
        
      end
      
      it "does not remove exisiting opportunities of other type" do
        
        badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").first(2).last
        
        Opportunity.create! user_id: @user.id, badge_type_id: badge_type.id
        
        opportunity = @review_summary.detect_opportunities
        
        expect(opportunity.badge_type_id).to eq @badge_type.id
        expect(Opportunity.count).to eq 2
        
      end
      
      it "does not remove exisiting opportunities of other users" do
        
        badge_type = BadgeType.where(badge_type: 'diligent').order("number_of_efforts_to_get ASC").first(2).last
        
        Opportunity.create! user_id: @user.id + 1, badge_type_id: badge_type.id
        
        opportunity = @review_summary.detect_opportunities
        
        expect(opportunity.badge_type_id).to eq @badge_type.id
        expect(Opportunity.count).to eq 2
        
      end
      
    end
    
    describe "detects 'warrior badge' opportunity" do
      
      before :each do
        @user = User.one
        @badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").first(3).last
        @review_summary = FactoryBot.create :review_summary, user_id: @user.id, date: today, number_of_reviewed_items_today: @badge_type.number_of_efforts_to_get
      end
      
      it "creates and returns an opportunity for the right badge type" do
        
        opportunity = @review_summary.detect_opportunities
        
        expect(opportunity).not_to be nil
        expect(opportunity.user_id).to eq @user.id
        expect(opportunity.badge_type_id).to eq @badge_type.id
        expect(opportunity.is_taken).to be false
        
      end
      
      it "does not create an opportunity and return nil if an opportunity of the same type and sub type exists" do
        
        Opportunity.create! user_id: @user.id, badge_type_id: @badge_type.id
        
        opportunity = @review_summary.detect_opportunities
        
        expect(Opportunity.count).to eq 1
        expect(opportunity).to be nil
        
      end
      
      it "removes exisiting opportunities for lower sub types of the same type" do
        
        badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").first
        
        Opportunity.create! user_id: @user.id, badge_type_id: badge_type.id
        
        opportunity = @review_summary.detect_opportunities
        
        expect(opportunity).not_to be nil
        expect(opportunity.badge_type_id).to eq @badge_type.id
        expect(Opportunity.count).to eq 1
        
      end
      
      it "does not remove exisiting opportunities of other type" do
        
        badge_type = BadgeType.where(badge_type: 'diligent').order("number_of_efforts_to_get ASC").first(2).last
        
        Opportunity.create! user_id: @user.id, badge_type_id: badge_type.id
        
        opportunity = @review_summary.detect_opportunities
        
        expect(opportunity.badge_type_id).to eq @badge_type.id
        expect(Opportunity.count).to eq 2
        
      end
      
      it "does not remove exisiting opportunities of other users" do
        
        badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").first(2).last
        
        Opportunity.create! user_id: @user.id + 1, badge_type_id: badge_type.id
        opportunity = @review_summary.detect_opportunities
        
        expect(opportunity).not_to be nil
        expect(opportunity.badge_type_id).to eq @badge_type.id
        expect(Opportunity.count).to eq 2
        
      end
      
    end
    
  end
  
  describe "clear obsolete summary data" do
    
    describe "clearing obsolete 'continuous_reviewing_days' summary attribute" do
      
      context "summary data hasn't been updated prior to yesterday" do
        
        before :each do
          @badge_type = BadgeType.where(badge_type: 'diligent').order("number_of_efforts_to_get ASC").first(2).last
          @review_summary = FactoryBot.create :review_summary, user_id: @user.id, date: today - 2.days, continuous_reviewing_days: 15
        end
        
        it "removes any 'diligent badge' opportunities" do
          
          Opportunity.create! user_id: @user.id, badge_type_id: @badge_type.id
          
          @review_summary.clear_obsolete_opportunities('diligent')
          
          expect(Opportunity.count).to be 0
                 
        end
        
        it "resets 'continuous_reviewing_days' summary attribute" do
          @review_summary.clear_obsolete_opportunities('diligent')
          expect(@review_summary.reload.continuous_reviewing_days).to be 0
        end
        
        it "doest not remove opportunities of other types" do
          Opportunity.create! user_id: @user.id, badge_type_id: BadgeType.where(badge_type: 'warrior').first.id
          @review_summary.clear_obsolete_opportunities('diligent')
          expect(Opportunity.count).to be 1
        end
        
        it "doest not remove 'diligent badge' opportunities of other users" do
          Opportunity.create! user_id: @user.id + 1, badge_type_id: @badge_type.id
          @review_summary.clear_obsolete_opportunities('diligent')
          expect(Opportunity.count).to be 1
        end
        
      end
      
      context "summary data has been updated yesterday or today" do
        
        before :each do
          @review_summary = FactoryBot.create :review_summary, user_id: @user.id, date: today - 1.days, continuous_reviewing_days: 15
        end
        
        it "does not remove 'diligent badge' opportunities" do
          
          badge_type = BadgeType.where(badge_type: 'diligent').order("number_of_efforts_to_get ASC").first
          
          Opportunity.create! user_id: @user.id, badge_type_id: badge_type.id
          
          @review_summary.clear_obsolete_opportunities('diligent')
          
          expect(Opportunity.count).to be 1
                 
        end
        
        it "does not reset 'continuous_reviewing_days' summary attribute" do
          @review_summary.clear_obsolete_opportunities('diligent')
          expect(@review_summary.reload.continuous_reviewing_days).to be 15
        end
        
      end
      
    end
    
    describe "clearing obsolete 'number_of_reviewed_items_today' summary attribute" do
      
      context "summary data hasn't been updated prior to today" do
        
        before :each do
          @badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").first(2).last
          @review_summary = FactoryBot.create :review_summary, user_id: @user.id, date: today - 1.days, number_of_reviewed_items_today: 50
        end
        
        it "removes any 'warrior badge' opportunities" do
          
          Opportunity.create! user_id: @user.id, badge_type_id: @badge_type.id
          
          @review_summary.clear_obsolete_opportunities('warrior')
          
          expect(Opportunity.count).to be 0
                 
        end
        
        it "resets 'number_of_reviewed_items_today' summary attribute" do
          @review_summary.clear_obsolete_opportunities('warrior')
          expect(@review_summary.reload.number_of_reviewed_items_today).to be 0
        end
        
        it "doest not remove opportunities of other types" do
          Opportunity.create! user_id: @user.id, badge_type_id: BadgeType.where(badge_type: 'diligent').first.id
          @review_summary.clear_obsolete_opportunities('warrior')
          expect(Opportunity.count).to be 1
        end
        
        it "doest not remove 'warrior badge' opportunities of other users" do
          Opportunity.create! user_id: @user.id + 1, badge_type_id: @badge_type.id
          @review_summary.clear_obsolete_opportunities('warrior')
          expect(Opportunity.count).to be 1
        end
        
      end
      
      context "summary data has been updated today" do
        
        before :each do
          @review_summary = FactoryBot.create :review_summary, user_id: @user.id, date: today, number_of_reviewed_items_today: 50
        end
        
        it "does not remove 'warrior badge' opportunities" do
          
          badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").first
          
          Opportunity.create! user_id: @user.id, badge_type_id: badge_type.id
          
          @review_summary.clear_obsolete_opportunities('warrior')
          
          expect(Opportunity.count).to be 1
                 
        end
        
        it "does not reset 'number_of_reviewed_items_today' summary attribute" do
          @review_summary.clear_obsolete_opportunities('warrior')
          expect(@review_summary.reload.number_of_reviewed_items_today).to be 50
        end
        
      end
      
    end
    
  end
  
end
