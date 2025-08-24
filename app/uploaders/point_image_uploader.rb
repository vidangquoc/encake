class PointImageUploader < BaseUploader
  
  version(:crop) do
    process :crop
  end
  
  version(:big, from_version: :crop) do
    process resize_to_fill: [500, 500]
  end

  version(:medium, from_version: :big) do
    process resize_to_fill: [400, 400]
  end

  version(:small, from_version: :medium) do
    process resize_to_fill: [300, 300]
  end

  private 

  def crop
    manipulate! do |image|
      if is_cropping?
        crop_image(image, model.cropping_data);
      end
      image
    end
  end
  
  def is_cropping?
    ! model.cropping_data.nil?
  end
  
end