FactoryBot.define do
  factory :push_notification do
    to_user_id { 1 }
    message { "This is a message" }
    sent { false }
    platform { 'android' }
    to_device_keys { ['ABC', 'DEF'] }
  end

end
