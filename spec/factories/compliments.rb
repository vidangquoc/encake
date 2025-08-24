FactoryBot.define do
  factory :compliment do
    from { "system" }
    for_task { "learn_vocabulary" }
    for_gender { "male" }
    content { "Very good!" }
    for_correctness_level { 1 }
  end
end
