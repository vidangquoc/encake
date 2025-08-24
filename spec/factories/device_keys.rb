FactoryBot.define do
  factory :device_key do
    user_id { 1 }
    sequence :key do |n|
      "device_key_#{n}"
    end
    platform { "android" }
  end

end
