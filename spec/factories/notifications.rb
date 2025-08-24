FactoryBot.define do
  factory :notification do
    to_user_id { "" }
    is_processed { false }
    data {}
  end
end
