class BadgeTypeImageUploader < BaseUploader
  process :resize_to_fit => [100,100]
end