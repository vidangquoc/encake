FactoryBot.define do
  
  factory :friend_teaser do
    sequence(:teasing_phase){|n| "Teasing #{n}" }
    is_active { true }
  end

end
