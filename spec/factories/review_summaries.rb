FactoryBot.define do
  factory :review_summary do
    user_id { 1 }
    date { "2017-04-07" }
    continuous_reviewing_days { 1 }
    number_of_reviewed_items_today { 1 }
  end
end
