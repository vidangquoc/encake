require 'spec_helper'
require File.dirname(__FILE__) + '/helpers/reviews.rb'

describe Api::V1000::ReviewsController do
  
  render_views

  before :each do
    
    prepare_review_test_data
    
    sign_in @user
    
  end
  
  describe "GET #load_points_being_reivewed" do
    
    before :each do
      @user.belongs_to_level Level.second
    end
    
    context "there is no skills in the requested skill that is reviewed today" do
      
      context "current review mode is learning" do
        
        it "returns correct data" do
        
          point1, point2 = Point.limit(2).to_a
          
          skills = [
            [point1.id, 'interpret'], [point1.id, 'grammar'], [point1.id, 'verbal'],
            [point2.id, 'interpret'], [point2.id, 'grammar'], [point2.id, 'verbal']
          ]
          
          get :load_points_being_reivewed, mode: 'learning', skills: skills
          
          should respond_with 200
          
          assert_returned_data_of_review(
            mode: 'learning',
            around_levels: Level.first(3).map(&:id),
            points_count: 2
          )
          
          expect(json_response.points.map(&:id)).to eq [point1.id, point2.id]
          
          assert_returned_point_data(json_response.points.first)
          
        end
        
      end
      
      context "current review mode is reviewing or reviewing_early" do
        
        before :each do
          
          add_points_to_bag(1..2)

          point1, point2 = Point.order('id').limit(2).to_a
          
          @skills = [
            [point1.id, 'interpret'], [point1.id, 'grammar'],
            [point2.id, 'interpret'], [point2.id, 'verbal'],
          ]
          
        end
        
        context "current review mode is reviewing" do
          
          it "returns correct data" do
          
            get :load_points_being_reivewed, mode: 'reviewing', skills: @skills
            
            should respond_with 200
            
            assert_returned_data_of_review(
              mode: 'reviewing',
              around_levels: Level.first(3).map(&:id),
              points_count: @skills.count
            )
            
            expect(json_response.points.map{|point| [point.id, point.reviewed_skill] }).to eq @skills
            
            assert_returned_point_data(json_response.points.first)
            
          end
          
        end
        
        context "current review mode is reviewing_early" do
          
          it "returns correct data" do
          
            get :load_points_being_reivewed, mode: 'reviewing_early', skills: @skills
            
            should respond_with 200
            
            assert_returned_data_of_review(
              mode: 'reviewing_early',
              around_levels: Level.first(3).map(&:id),
              points_count: @skills.count
            )
            
            expect(json_response.points.map{|point| [point.id, point.reviewed_skill] }).to eq @skills
            
            assert_returned_point_data(json_response.points.first)
            
          end
          
        end
            
      end
      
    end
    
    context "there is no skills in the requested skill that is reviewed today" do
      
      it "returns correct status code" do
        
        review_skills = add_points_to_bag(1..2)
          
        @interpret_1, @reverse_interpret_1, @grammar_1 = review_skills[0]
        
        point1, point2 = Point.order('id').limit(2).to_a
        
        @skills = [
          [point1.id, 'interpret'], [point1.id, 'grammar'],
          [point2.id, 'interpret'], [point2.id, 'verbal'],
        ]
        
        @interpret_1.update_attributes last_reviewed_date: today, review_due_date: today + 10.days
        
        get :load_points_being_reivewed, mode: 'any', skills: @skills
        
        should respond_with 409
        
      end
      
    end
    
  end
  
  describe "GET load_points_of_lesson_for_previewing" do
      
    context "limit param is not set" do
    
      it "returns correct data" do
        
        @user.belongs_to_level Level.second
        
        lesson = Lesson.first
        
        get :load_points_of_lesson_for_previewing, lesson_id: lesson.id
        
        should respond_with 200
        
        assert_returned_data_of_review(
          mode: 'learning',
          around_levels: Level.first(3).map(&:id),
          points_count: lesson.points.size
        )
        
        expect(json_response.points.map(&:id).sort).to eq lesson.points.map(&:id)
        
        assert_returned_point_data(json_response.points.first)
        
      end
      
    end
    
    context "limit param is set" do
    
      it "returns correct data" do
        
        @user.belongs_to_level Level.second
        
        lesson = Lesson.first
        
        limit = 2
        
        get :load_points_of_lesson_for_previewing, lesson_id: lesson.id, limit: limit
        
        should respond_with 200
        
        assert_returned_data_of_review(
          mode: 'learning',
          around_levels: Level.first(3).map(&:id),
          points_count: limit
        )
        
        assert_returned_point_data(json_response.points.first)
        
      end
      
    end
    
  end
  
  describe "POST detect_linked_skills_of_example_and_mark_as_reminded" do
    
    before :each do
      
      add_points_to_bag(1..2)
      
      ReviewSkill.update_all effectively_reviewed_times: 5, last_reviewed_date: 10.days.ago
      
      @point1, @point2 = Point.order('id').limit(2).to_a
      
      @interpret_2 = find_review_skill(@point2.id, :interpret)
      
      @verbal_2 = find_review_skill(@point2.id, :verbal)
      
      @example = @point1.main_example
      
      @example.has_example_point_links([{point_id: @point2.id}])
      
    end
    
    it "returns ok status code" do
      
      post :detect_linked_skills_of_example_and_mark_as_reminded, example_id: @example.id, point_ids: [@point1.id, @point2.id]
      
      should respond_with 200
    
    end
    
    it "detects linked interpret skills of the example and mark them as reminded" do
      
      post :detect_linked_skills_of_example_and_mark_as_reminded, example_id: @example.id, point_ids: [@point1.id, @point2.id]
      
      expect(@interpret_2.reload.effectively_reviewed_times).to be 2
      
      expect(@verbal_2.reload.effectively_reviewed_times).to be 5
      
    end
    
    it "does not affect linked interpret skills that do not belongs to current user" do
      
      user2 = User.one
      review = user2.has_1_reviews(:assoc).belongs_to([@point2]).first
      
      interpret, verbal = review.has_review_skills([
        {skill: ReviewSkill::SKILLS.fetch(:interpret)},        
        {skill: ReviewSkill::SKILLS.fetch(:verbal)},
      ], :assoc)
      
      ReviewSkill.update_all effectively_reviewed_times: 5, last_reviewed_date: 10.days.ago
      
      post :detect_linked_skills_of_example_and_mark_as_reminded, example_id: @example.id, point_ids: [@point1.id, @point2.id]  
      
      expect(interpret.reload.effectively_reviewed_times).to be 5
      
    end
    
  end
  
  describe "PUT reset_effectively_reviewed_times" do
    
    before :each do
      
      add_points_to_bag(1..2)
      
      ReviewSkill.update_all effectively_reviewed_times: 5, reviewed_times: 10, last_reviewed_date: 10.days.ago
      
      @point1, @point2 = Point.order('id').limit(2).to_a
      
      @interpret_2 = find_review_skill(@point2.id, :interpret)
      
      @verbal_2 = find_review_skill(@point2.id, :verbal)
      
    end
    
    it "returns ok status code" do
      
      put :reset_effectively_reviewed_times, point_id: @point2.id
      
      should respond_with 200
    
    end
    

    it "resets the number of effectively reviewed times of 'interpret' skill" do
      
      put :reset_effectively_reviewed_times, point_id: @point2.id
      
      should respond_with 200
      
      @interpret_2.reload
      expect(@interpret_2.effectively_reviewed_times).to be 1
      expect(@interpret_2.reviewed_times).to be 11
      
    end
    
    it "does not reset the number of effectively reviewed times of 'interpret' which does not belong to current user" do
      
      user2 = User.one
      review = user2.has_1_reviews(:assoc).belongs_to([@point2]).first
      
      interpret, verbal = review.has_review_skills([
        {skill: ReviewSkill::SKILLS.fetch(:interpret)},        
        {skill: ReviewSkill::SKILLS.fetch(:verbal)},
      ], :assoc)
      
      ReviewSkill.update_all effectively_reviewed_times: 5, last_reviewed_date: 10.days.ago
      
      put :reset_effectively_reviewed_times, point_id: @point2.id
      
      expect(interpret.reload.effectively_reviewed_times).to be 5
      
    end

  
  end

end