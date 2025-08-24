# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :list do
    name { "Category Name" }
    is_standard { true }    
  end
end
