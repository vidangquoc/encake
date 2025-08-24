# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :grammar_point do
    lesson_id { 0 }
    sequence(:content){|n| "Grammar Point #{n}" }
  end
end
