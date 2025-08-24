module CommonHelper
  
  module Helpers
    
    def stub_rpush_apps
      allow(Rpush::Gcm::App).to receive(:find_by_name).with('android').and_return(PushNotification.create_rpush_apps)
    end
    
    def today
      DateTime.now.to_date
    end
    
    def stub_network_calls_that_get_data_for_points
      allow(Network::TextToSpeech).to receive(:word_to_speech).and_return(nil)
      allow(Network::TextToSpeech).to receive(:phase_to_speech).and_return(nil)
      allow(Network::WordPronunciation).to receive(:fetch_for).and_return({possible_pronunciations: ['lʌv', 'lap'], valid_pronunciation: 'lʌv'});
      allow(Network::WordMeaning).to receive(:fetch_for).and_return([])
    end
    
    def create_badge_types
      BadgeType::BADGE_TYPES.each do |type|
        5.times do |n|
          FactoryBot.create :badge_type, badge_type: type, number_of_efforts_to_get: 30*(n + 1)
        end
      end
    end
    
    def find_badge_type(badge_type, order = 3)
      BadgeType.where(badge_type: badge_type).order('number_of_efforts_to_get ASC').limit(order).last
    end
    
  end
  
end