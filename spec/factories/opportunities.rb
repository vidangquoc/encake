FactoryBot.define do
  factory :opportunity do
    user_id { 1 }
    badge_type_id { 1 }
    is_taken { false }
  end
end
