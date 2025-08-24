FactoryBot.define do
  factory :point_image do
    point_id { 1 }
    image do
      images = %w{lovely_baby.jpeg lovely_boy.jpg lovely_boy.jpg lovely_cat.jpg lovely_doggy.jpg lovely_girl.jpg lovely_teen_girl.jpg lovely_woman.jpeg}
      Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'factories', 'sample_images', images.sample), 'image/jpg')
    end
    cropping_data do
      {x: 0, y: 0, width: 10000, height: 10000}
    end
  end
end