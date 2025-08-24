# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :invitation do
    sender_id { 0 }   
    sequence(:receiver_email){|n| "example_#{n}@gmail.com"}   
  end
end
