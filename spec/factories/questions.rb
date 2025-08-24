# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  
  factory :question do
    
    sequence(:content) {|n| "Question #{n} contains {...}" }
    point_id { 0 }
    sequence(:question_type){|n|
      Question::TYPES.keys[n%Question::TYPES.keys.length].to_s
    }
    right_answer_explanation_id { 0 }
    right_answer_explanation_parts { "Bob; Tom; Jerry" }
    answer { "The answer" }
    
    factory :valid_question do
      is_valid { true }
    end
    
  end
  
end

