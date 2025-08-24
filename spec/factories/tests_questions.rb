# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :tests_question, :class => 'TestsQuestions' do
    test_id { 1 }
    answer_id { 1 }
  end
end
