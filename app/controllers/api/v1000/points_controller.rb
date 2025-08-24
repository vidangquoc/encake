module Api;module V1000

  class PointsController < BaseController
    
    caches_page :types
    
    def index

      number_of_items = params[:number_of_items].to_i
      page = params[:page].to_i
      @points = Point.includes_for_search_by_user.
                search_by_user(current_user.id, search_in: params[:search_in].to_sym, content: params[:content])
                .order('content ASC, point_type ASC').offset((page - 1)*number_of_items).limit(number_of_items).to_a
      
      render template: "api/points/points.json"
    end
    
    def search_including_variations

      @points = Point.search_including_variations(params[:key], current_user.id)
      
      render template: "api/points/points.json"

    end
    
    def create
      
      point = Point.build_by_user_with_example(current_user.id, point_params)
      
      skip_finding_sound_and_pronunciation_for_point?(point)

      if point.valid?
        Point.save_by_user_with_example(current_user.id, point)
        render json: {message: "Đã thêm từ"}
      else
        render json: point.errors.messages, status: :unprocessable_entity
      end
      
    end
    
    def edit
      @point = Point.find(params[:id])
      render template: "api/points/point.json"
    end
    
    def update
      
      point = Point.find(params[:id])
      
      render json: {message: 'Bạn không được phép cập nhật mục này!'}, status: :unauthorized and return if point.adding_user_id != current_user.id

      if !point.main_example 
        point.main_example = Example.new(point_id: point.id)
      end
      
      point.main_example.attributes = point_params.slice(:main_example_attributes).values[0]
      
      point.attributes = point_params.except!(:main_example_attributes)

      skip_finding_sound_and_pronunciation_for_point?(point)
      
      if point.valid?
        point.save!
        render json: {message: "Đã cập nhật"}
      else
        render json: point.errors.messages, status: :unprocessable_entity 
      end
      
    end
    
    def destroy
      
      point = Point.find(params[:id])
      
      render json: {message: 'Bạn không được phép xóa mục này!'}, status: :unauthorized and return if point.adding_user_id != current_user.id
      
      point.destroy
      
      render json: {}
    
    end
    
    def types
      render json: Point::POINT_TYPES  
    end
        
    private
    
    def point_params
      params.require(:point).permit(:content, :split_content, :point_type, :meaning, :meaning_in_english, :pronunciation, :main_example_attributes => [:content, :meaning])
    end

    def skip_finding_sound_and_pronunciation_for_point?(point)
      
      if current_user.email == 'esperanto@encake.com'
        point.skip_finding_sound = true
        point.skip_finding_pronunciation = true
        point.main_example.skip_finding_sound = true if point.main_example
      end

    end
    
  end

end;end