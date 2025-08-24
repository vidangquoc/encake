# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :friendship do
    user_id { 0 }
    friend_id { 0 }    
  end
end
