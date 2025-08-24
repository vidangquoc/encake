# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :taken_test_item do
    taken_test_id { "" }
    question_id { "" }
    chosen_answer_id { 1 }
  end
end
