module Api;module V1000
  
  class ReviewsController < BaseController
        
    def init_review
      
      @around_levels = current_user.level.around_levels
      
      @number_of_learnt_points = current_user.reviews.size
      
      forced_mode = params[:forced_mode] || 'none'
      
      load_review_data(forced_mode)
      
      render template: "api/reviews/init_review.json"
      
    end
    
    def process_review
      
      reminded_times = params[:reminded_times].map{|item| [item['skill_id'], item['reminded_times'], item['is_mastered']]}
      skill_ids = reminded_times.map{|item| item[0] } 
      
      if valid_skill_id_exist(skill_ids)
        @process_review_result = current_user.process_review(reminded_times)
      else
        learning_data = params[:reminded_times].map{ |i| { point_id: i['point_id'], skill_symbol: i['skill_symbol'].to_sym, reminded_times: i['reminded_times'].to_i, is_mastered:i['is_mastered']} }
        @process_review_result = current_user.put_points_to_bag(learning_data)
        @number_of_learnt_points = learning_data.map{|item| item[:point_id]}.uniq.count
      end
      
      @around_levels = current_user.reload.level.around_levels if @process_review_result[:level_changed] != 0
      
      forced_mode = params[:forced_mode] || 'none'
      
      load_review_data(forced_mode)
    
      render template: "api/reviews/process_review.json"
      
    end
  
    def load_points_being_reivewed
      
      @mode = params[:mode]
      
      skills = params[:skills]
      
      if ! current_user.today_reviewed_skills_exist?(skills)
      
        @around_levels = current_user.reload.level.around_levels
        
        @number_of_learnt_points = current_user.reviews.size
        
        @number_of_due_points = current_user.number_of_due_points
        
        if @mode == 'learning'
          
          point_ids = skills.map{|skill| skill[0]}.uniq
          
          @points = Point.get_by_ids(point_ids)              
          
        else
          
          @points = current_user.load_points_by_skills(skills)
        
        end
        
        render template: "api/reviews/init_review.json"
        
      else
        
        render json: {}, status: :conflict 
        
      end
      
    end
    
    def load_points_of_lesson_for_previewing
      
      @around_levels = current_user.reload.level.around_levels
        
      @number_of_learnt_points = current_user.reviews.size
      
      @number_of_due_points = current_user.number_of_due_points
      
      @mode = 'learning'
      
      #@points = Point.where(lesson_id: params[:lesson_id], is_private: false)
      #                .where(["is_valid = ? OR is_supporting = ?", true, true])
      
      @points = Point.where(lesson_id: params[:lesson_id]).limit(1)
                      
      if !params[:limit].nil?
        @points = @points.limit(params[:limit].to_i)  
      end
      
      render template: "api/reviews/init_review.json"
      
    end
    
    def detect_linked_skills_of_example_and_mark_as_reminded
    
      example = Example.find_by(id: params[:example_id])
      point_ids = params[:point_ids].map(&:to_i)
      
      if !example.nil? and point_ids.any?
        
        matched_point_ids = point_ids & example.example_point_links.map(&:point_id)

        if matched_point_ids.any?

          review_skills = current_user.review_skills.where(["reviews.point_id in (?)", matched_point_ids]).where(skill: ReviewSkill::SKILLS.fetch(:interpret))

          review_skills.each do |review_skill|
            review_skill.process_review(1)
            review_skill.save
          end

        end
        
      end
    
      render json: {}
    
  end
  
  def reset_effectively_reviewed_times
    
    point_id = Point.find(params[:point_id])
    review_skill = current_user.review_skills.where(["reviews.point_id = ?", point_id]).where(skill: ReviewSkill::SKILLS[:interpret]).first
    review_skill.process_review(3)
    review_skill.save!
    
    render json: {status: 'OK'}
  end
    
    private
    
    def load_review_data(forced_mode)
      
      @number_of_due_points = current_user.number_of_due_points
      
      if forced_mode == 'none'
      
        if @number_of_due_points > 0
          
          @points = get_points_to_review
          
          @mode = 'reviewing'
          
        else
          
          @points = get_new_points_to_learn
          
          if @points.count > 0
            
            @mode = 'learning'
            
          else
            
            @points = get_points_to_review_early
            
            @mode = 'reviewing_early'
            
          end
          
        end
      
      elsif forced_mode == 'learning'
        
        @points = get_new_points_to_learn
        
        @mode = 'learning'
        
      elsif forced_mode == 'reviewing'
        
        @points = get_points_to_review
        
        @mode = 'reviewing'
        
        if @points.to_a.count == 0
          
          @points = get_points_to_review_early
          
          @mode = 'reviewing_early'
          
        end
        
      end
      
    end
    
    def valid_skill_id_exist(skill_ids)
      skill_ids.any?{|skill_id| !skill_id.nil? && skill_id.to_i > 0}
    end
    
    def get_points_to_review
      current_user.points_for_review(Constants.number_of_skills_for_reviewing)
    end
    
    def get_new_points_to_learn
      current_user.new_points_to_learn(Constants.number_of_new_points_to_learn)
    end
    
    def get_points_to_review_early
      current_user.points_for_review_early(Constants.number_of_skills_for_reviewing)
    end
    
  end
  
end;end