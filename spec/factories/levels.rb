# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  
  factory :level do
    
    sequence(:highest_score){|n| n*300}
    
  end
    
end