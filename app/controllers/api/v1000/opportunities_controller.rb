module Api;module V1000

  class OpportunitiesController < BaseController
    
    def ignore
      Opportunity.find(params[:opportunity_id]).ignore
      render json: {}, status: :ok
    end
    
    def take
      render json: { is_won: Opportunity.find(params[:opportunity_id]).take( params[:number_of_used_lucky_stars].to_i ) }
    end
    
  end
  
end;end