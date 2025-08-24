require 'spec_helper'
require File.dirname(__FILE__) + '/helpers/reviews.rb'

describe Api::V1000::ReviewsController do
  
  render_views

  before :each do
    
    prepare_review_test_data
    
    sign_in @user
    
  end

  describe "GET #init_review" do
    
    before :each do
      @user.belongs_to Level.second
    end
    
    context "forced mode is 'none'" do
      
      before :each do
        @forced_mode = 'none'
      end
      
      context "there are due skills" do
      
        it "returns correct data" do

          add_points_to_bag(1..3)
          
          assert_returned_data_of_review_init(
            mode: 'reviewing',
            around_levels: Level.first(3).map(&:id),
            points_count: Constants.number_of_skills_for_reviewing
          )
          
        end
        
      end
      
      context "there are no due skills, but there are new points to learn" do
        
        it "returns correct data" do

          assert_returned_data_of_review_init(
            mode: 'learning',
            around_levels: Level.first(3).map(&:id),
            points_count: Constants.number_of_new_points_to_learn
          )
          
        end
        
      end
      
      context "there are no due skills and there are no new points to learn" do
        
        it "returns correct data" do

          add_all_points_to_bag
          
          make_all_review_skills_undue
          
          assert_returned_data_of_review_init(
            mode: 'reviewing_early',
            around_levels: Level.first(3).map(&:id),
            points_count: Constants.number_of_skills_for_reviewing
          )
          
        end
        
      end
      
    end
    
    context "forced mode is 'learning'" do
      
      before :each do
        @forced_mode = 'learning'
      end
      
      context "there are new points to learn" do
      
        it "returns correct data" do

          add_points_to_bag(1..3)
               
          assert_returned_data_of_review_init(
            mode: 'learning',
            around_levels: Level.first(3).map(&:id),
            points_count: Constants.number_of_new_points_to_learn
          )
          
        end
        
      end
      
      context "there are no new points to learn" do
        
        it "returns correct data" do

          add_all_points_to_bag()

          assert_returned_data_of_review_init(
            mode: 'learning',
            around_levels: Level.first(3).map(&:id),
            points_count: 0
          )
          
        end
        
      end
      
    end
    
    context "forced mode is 'reviewing'" do
      
      before :each do
        @forced_mode = 'reviewing'
      end
          
      context "there are due skills" do
      
        it "returns correct data" do
          
          add_points_to_bag(1..3)
          
          assert_returned_data_of_review_init(
            mode: 'reviewing',
            around_levels: Level.first(3).map(&:id),
            points_count: Constants.number_of_skills_for_reviewing
          )
          
        end
        
      end
      
      context "there are no due skills, but there are skills that can be reviewed early" do
                
        it "returns correct data" do
          
          add_points_to_bag(1..3)
          
          make_all_review_skills_undue
          
          assert_returned_data_of_review_init(
            mode: 'reviewing_early',
            around_levels: Level.first(3).map(&:id),
            points_count: Constants.number_of_skills_for_reviewing
          )
          
        end
        
      end
      
      context "all skills are reviewed today" do
        
        it "returns correct data" do
          
          add_points_to_bag(1..3)
          
          make_all_review_skills_reviewed_today
          
          assert_returned_data_of_review_init(
            mode: 'reviewing_early',
            around_levels: Level.first(3).map(&:id),
            points_count: 0
          )
          
        end
        
      end
      
    end
    
  end
 
end