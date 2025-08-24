FactoryBot.define do
  factory :user_ui_action do
    user_id { 1 }
    action { "click" }
    action_data { "x-y" }
    action_time { 1474018536225 }
    view { "abc" }
    device { "ios" }
  end
end
