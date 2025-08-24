# encoding: utf-8

class AvatarUploader < BaseUploader
  
  # Provide a default URL as a default if there hasn't been a file uploaded:
  #def default_url
  #  ActionController::Base.helpers.asset_path("fallback/" + [version_name, "avatar.jpg"].compact.join('_'))
  #end
  
  process :crop
  process :resize_to_limit => [400,400]
  
  version :thumb do
    process :resize_to_fill => [200, 200]
  end

  private 

  def crop
    manipulate! do |image|
      if is_cropping?
        crop_image(image, model.avatar_cropping_data);
      end
    end
  end
  
  def is_cropping?
    ! model.avatar_cropping_data.nil?
  end

end
