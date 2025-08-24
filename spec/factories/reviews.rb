FactoryBot.define do
  factory :review do
    user_id { 1 }
    point_id { 1 }
    is_active { true }
  end
end