# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :taken_test do
    user_id { 0 }    
    finished {[true, false].sample}
    is_passed {[true, false].sample}
  end
end
