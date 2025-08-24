# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :administrator do
    
    email { "super@encake.com" }
    password { "vidaica" }    
    role { "super" }
    
    factory :moderator do
      email { 'moderator@encake.com' }
      role { 'moderator' }
    end
    
  end
end
