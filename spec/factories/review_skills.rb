FactoryBot.define do
  factory :review_skill do
    review_id { 1 }
    reviewed_times { 1 }
    effectively_reviewed_times { 1 }
    review_due_date { "2016-05-05" }
    last_reviewed_date { "2016-05-05" }
    reminded_times { 1 }
    skill { 0 }
  end

end
