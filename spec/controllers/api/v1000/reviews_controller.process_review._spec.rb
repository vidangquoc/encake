require 'spec_helper'
require File.dirname(__FILE__) + '/helpers/reviews.rb'

describe Api::V1000::ReviewsController do
  
  render_views

  before :each do
    
    prepare_review_test_data
      
    sign_in @user
    
  end
  
  describe "POST #process_review" do
    
    context "forced mode is 'none'" do
      
      before :each do
        @forced_mode = "none"
        add_points_to_bag(1..2)
      end
      
      context "due skills are being reviewed" do
      
        context "there will still be due skills after review data is processed" do
          
          before :each do
            @practicing_data = build_review_data_for_points(1..1) # + 3 score after being processed
          end
          
          it{ assert_returned_data_of_review_proccess(
            mode: 'reviewing',
            points_count: Constants.number_of_skills_for_reviewing
          )}
          
          it{ assert_returned_around_levels_review_proccess }
        
        end
      
        context "there will be no due skills after review data is processed" do
        
          before :each do
            @practicing_data = build_review_data_for_points(1..2)
          end
          
          it{ assert_returned_data_of_review_proccess(
            mode: 'learning',
            points_count: Constants.number_of_new_points_to_learn
          )}
        
          it{ assert_returned_around_levels_review_proccess }
        
        end
      
        context "there will be no due skills and no new points after review data is processed" do
        
          before :each do
            
            add_all_points_to_bag
            
            make_all_review_skills_undue
            
            @practicing_data = build_review_data_for_points(1..2)
            
          end
          
          it{ assert_returned_data_of_review_proccess(
            mode: 'reviewing_early',
            points_count: Constants.number_of_skills_for_reviewing,
          )}
      
          it{ assert_returned_around_levels_review_proccess }
        
        end
      
        context "there will be nothing to review after review data is processed" do
        
          before :each do
            
            add_all_points_to_bag
            
            make_all_review_skills_reviewed_today
            
            @practicing_data = build_review_data_for_points(1..2)
            
          end
          
          it{ assert_returned_data_of_review_proccess(
            mode: 'reviewing_early',
            points_count: 0,
          )}
          
          it{ assert_returned_around_levels_review_proccess }
      
        end
        
      end
    
      context "new points are being learnt" do
      
        before :each do
          make_all_review_skills_undue
        end
        
        context "there will still be new points after review data is processed" do
          
          before :each do
            @practicing_data = build_learning_data_for_points(3..4)
          end
          
          it{ assert_returned_data_of_review_proccess(
            mode: 'learning',
            points_count: Constants.number_of_new_points_to_learn,
            learnt_points: 2,
          )}
          
          it{ assert_returned_around_levels_review_proccess }
        
        end
      
        context "there will be no new points after review data is processed" do
        
          before :each do
            @practicing_data = build_learning_data_for_points(3..4)
            destroy_points_greater_than(4)
          end
          
          it{ assert_returned_data_of_review_proccess(
            mode: 'reviewing_early',
            points_count: Constants.number_of_skills_for_reviewing,
            learnt_points: 2,
          )}
        
          it{ assert_returned_around_levels_review_proccess }
        
        end
      
        context "there will be nothing to review after review data is processed" do
        
          before :each do
            
            destroy_points_greater_than(4)
            
            add_points_to_bag(1..2)
            
            make_all_review_skills_reviewed_today
            
            @practicing_data = build_learning_data_for_points(3..4)
            
          end
          
          it{ assert_returned_data_of_review_proccess(
            mode: 'reviewing_early',
            points_count: 0,
            learnt_points: 2,
          )}
          
          it{ assert_returned_around_levels_review_proccess }
      
        end
          
      end
    
    end
  
    context "forced mode is 'learning'" do
    
      before :each do
        @forced_mode = "learning"
        add_points_to_bag(1..2)
      end
      
      context "there will still be new points after review data is processed" do
        
        before :each do
          @practicing_data = build_learning_data_for_points(3..4)
        end
        
        it{ assert_returned_data_of_review_proccess(
          mode: 'learning',
          points_count: Constants.number_of_new_points_to_learn,
          learnt_points: 2,
        )}
        
        it{ assert_returned_around_levels_review_proccess }
      
      end
    
      context "there will be no new points after review data is processed" do
      
        before :each do
          @practicing_data = build_learning_data_for_points(3..4)
          destroy_points_greater_than(4)
        end
        
        it{ assert_returned_data_of_review_proccess(
          mode: 'learning',
          points_count: 0,
          learnt_points: 2,
        )}
      
        it{ assert_returned_around_levels_review_proccess }
      
      end
    
    end
  
    context "forced mode is 'reviewing'" do
      
      before :each do
        @forced_mode = "reviewing"
      end
      
      context "there will still be due skills after review data is processed" do
          
        before :each do
          add_points_to_bag(1..2)
          @practicing_data = build_review_data_for_points(1..1) # + 4 score after being processed
        end
        
        it{ assert_returned_data_of_review_proccess(
          mode: 'reviewing',
          points_count: Constants.number_of_skills_for_reviewing
        )}
        
        it{ assert_returned_around_levels_review_proccess }
      
      end
    
      context "there will be no due skills after review data is processed" do
      
        before :each do
          add_points_to_bag(1..4)
          make_all_review_skills_undue
          @practicing_data = build_review_data_for_points(3..4)
        end
        
        it{ assert_returned_data_of_review_proccess(
          mode: 'reviewing_early',
          points_count: Constants.number_of_skills_for_reviewing
        )}
      
        it{ assert_returned_around_levels_review_proccess }
      
      end
    
      context "there will be nothing to review after review data is processed" do
      
        before :each do
          
          add_all_points_to_bag
          
          make_all_review_skills_reviewed_today
          
          @practicing_data = build_review_data_for_points(1..2)
          
        end
        
        it{ assert_returned_data_of_review_proccess(
          mode: 'reviewing_early',
          points_count: 0,
        )}
        
        it{ assert_returned_around_levels_review_proccess }
    
      end
    
    end
  
    context "an opportunity is detected" do
      
      context "next sub type exists" do
      
        before :each do          
          @badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").first(3).last
          @next_badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").first(4).last
          FactoryBot.create :review_summary, user_id: @user.id, date: today, number_of_reviewed_items_today: @badge_type.number_of_efforts_to_get
        end
        
        context 'learning mode' do
        
          it "returns the detected opportunity" do
              
            post :process_review, forced_mode: 'learning', reminded_times: build_learning_data_for_points(1..2)
                    
            assert_returned_opportunity(json_response, @badge_type, @next_badge_type)
            
          end
        
        end
      
        context 'reviewing mode' do
        
            it "returns the detected opportunity" do
                
              post :process_review, forced_mode: 'reviewing', reminded_times: build_review_data_for_points(1..2)
                      
              assert_returned_opportunity(json_response, @badge_type, @next_badge_type)
              
            end
          
        end
        
        context 'reviewing_early mode' do
          
            it "returns the detected opportunity" do
                
              post :process_review, forced_mode: 'reviewing_early', reminded_times: build_review_data_for_points(1..2)
                      
              assert_returned_opportunity(json_response, @badge_type, @next_badge_type)
            
          end
        
        end
    
      end
      
      context "next sub type does not exist" do
      
        before :each do
          @badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").last
          FactoryBot.create :review_summary, user_id: @user.id, date: today, number_of_reviewed_items_today: @badge_type.number_of_efforts_to_get
        end
        
        context 'learning mode' do
        
          it "returns the detected opportunity" do
              
            post :process_review, forced_mode: 'learning', reminded_times: build_learning_data_for_points(1..2)
                    
            assert_returned_opportunity(json_response, @badge_type, nil)
            
          end
        
        end
      
        context 'reviewing mode' do
        
            it "returns the detected opportunity" do
                
              post :process_review, forced_mode: 'reviewing', reminded_times: build_review_data_for_points(1..2)
                      
              assert_returned_opportunity(json_response, @badge_type, nil)
              
            end
          
        end
        
        context 'reviewing_early mode' do
          
            it "returns the detected opportunity" do
                
              post :process_review, forced_mode: 'reviewing_early', reminded_times: build_review_data_for_points(1..2)
                      
              assert_returned_opportunity(json_response, @badge_type, nil)
            
          end
        
        end
    
      end
      
    end
    
    context "no opportunity is detected" do
      
      before :each do
        FactoryBot.create :review_summary, user_id: @user.id, date: today, number_of_reviewed_items_today: 0
      end
      
      it "returns null" do
          
        post :process_review, forced_mode: 'learning', reminded_times: build_learning_data_for_points(1..2)
                
        expect(json_response.process_review_result.opportunity).to be nil
        expect(json_response.process_review_result.number_of_lucky_stars).to be nil
        
      end
      
    end
    
    describe "rewarded lucky stars" do
      
      context 'learning mode' do
        
        it "returns the number of rewarded lucky stars" do
          
          allow(Badge).to receive(:toss_lucky_stars_to_user).and_return(6)
            
          post :process_review, forced_mode: 'learning', reminded_times: build_learning_data_for_points(1..2)
                  
          expect(json_response.process_review_result.number_of_rewarded_lucky_stars).to eq 6
          
        end
      
      end
    
      context 'reviewing mode' do
      
          it "returns the number of rewarded lucky stars" do
            
            allow(Badge).to receive(:toss_lucky_stars_to_user).and_return(7)
              
            post :process_review, forced_mode: 'reviewing', reminded_times: build_review_data_for_points(1..2)
                    
            expect(json_response.process_review_result.number_of_rewarded_lucky_stars).to eq 7
            
          end
        
      end
      
      context 'reviewing_early mode' do
          
          it "returns the number of rewarded lucky stars" do
            
            allow(Badge).to receive(:toss_lucky_stars_to_user).and_return(8)
            
            post :process_review, forced_mode: 'reviewing_early', reminded_times: build_review_data_for_points(1..2)
                    
            expect(json_response.process_review_result.number_of_rewarded_lucky_stars).to eq 8
          
        end
      
      end
      
    end
    
  end

end