module Api;module V1000
  
  class SoundsController < BaseController
    
    skip_before_filter :authenticate
    caches_page :show
    
    def show
      expires_in 100.years, public: true
      @sound = Sound.find_by(id: params[:id], updated_at: Time.at(params[:version].to_i).to_datetime.utc.to_s(:db))
      respond_to do |format|
        format.mp3 { send_data @sound.mp3, :type => 'audio/mpeg', :disposition => 'inline' }
      end
    end
    
  end
    
end;end
