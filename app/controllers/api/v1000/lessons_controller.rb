module Api;module V1000

  class LessonsController < BaseController
  
    def show
      
      @lesson = Lesson.find params[:id]
      
      @lesson.process_content_for_show
      
      render json: @lesson
      
    end
  
  end

end;end