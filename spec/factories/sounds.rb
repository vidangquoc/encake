# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :sound do
    
    sequence(:for_content){|n| "content #{n}" }
    
    after(:create) do |s|
      sound_file = Point.where(:content => s.for_content).any? ? 'sample_sounds/admiration.mp3' : 'sample_sounds/i_love_you.mp3'
      s.mp3 = File.open(Rails.root.join('spec','factories',sound_file), 'rb'){ |io| io.read }    
      s.save
    end
    
  end
end