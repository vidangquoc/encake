# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :lesson do
    sequence(:name) {|n| "Lesson #{n}" }
    sequence(:content) {|n| File.read(Rails.root.join('spec','factories','sample_lesson_contents', "#{((n-1) % 5) + 1}.html")) }
    syllabus_id { 0 }
    active { true }
    master_lesson_id { nil }
  end
end
