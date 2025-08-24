FactoryBot.define do
  factory :badge_type do
    badge_type { "diligent" }
    sequence(:name){ |n| "Badge Number ##{n}" }
    sequence(:number_of_efforts_to_get){|n| 400*n }
    image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'factories', 'sample_images', 'warrior.png'), 'image/png') }
  end
end