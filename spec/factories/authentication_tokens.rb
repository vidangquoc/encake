FactoryBot.define do
  factory :authentication_token do
    user_id { 1 }
    token { rand(100000000000000000) } 
    user_type { 'active' }
  end
end
