# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :point do    
    lesson_id { 0 }
    is_valid { true }
    sequence(:content) {|n| "Point #{n}"}
    sequence(:split_content) {|n| "Point.#{n}"}
    sequence(:google_search_key) {|n| "At point #{n}"}
    point_type { 'n' }
    meaning_in_english { "Meaning in english" }
    sequence(:meaning) {|n| "Điểm #{n}"}
    sound_id { 0 }
    sequence(:pronunciation) {|n| "pɔint #{n}"}
  end
end
