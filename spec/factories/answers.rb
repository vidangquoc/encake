# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  
  factory :answer do
    
    sequence(:content){|n| "Answer #{n}"}   
    question_id { 0 }
    
    factory :right_answer do
      is_right { true }
    end
    
  end
end
