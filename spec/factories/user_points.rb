# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :user_point do
    user_id { 0 }
    point_id { 0 }
    reviewed_times { 0 }
    reminded_times { 0 }
    effectively_reviewed_times { 0 }    
  end
end
