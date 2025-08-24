FactoryBot.define do
  factory :right_answer_explanation do
    lesson_id { 1 }
    explanation { "{1} is very good, but I like {2} more. However I will go with {3}" }
  end

end
