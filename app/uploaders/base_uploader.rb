class BaseUploader < CarrierWave::Uploader::Base
  
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog
  
  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  # Add a white list of extensions which are allowed to be uploaded. 
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
   # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  
  def filename
    @name ||= "#{timestamp}_#{super}" if original_filename.present? and super.present?
  end
  
  
  #def filename
  #  if original_filename
  #    if model && model.read_attribute(mounted_as).present?
  #      model.read_attribute(mounted_as)
  #    else
        # new filename
  #      "#{timestamp}_#{super}"
  #    end
  #  end
  #end

  def timestamp
    var = :"@#{mounted_as}_timestamp"
    model.instance_variable_get(var) or model.instance_variable_set(var, Time.now.to_i)
  end

  protected

  def crop_image(image, cropping_data)

    cropping_data = {} if !cropping_data

    width = cropping_data.fetch(:width).to_i
    height = cropping_data.fetch(:height).to_i;
    width_offset = cropping_data.fetch(:x).to_i;
    height_offset = cropping_data.fetch(:y).to_i;
    
    if width_offset < 0
      width = width + width_offset
      width_offset = 0
    end
    
    if height_offset < 0
      height = height + height_offset
      height_offset = 0
    end
    
    max_width = image.width - width_offset
    max_height = image.height - height_offset
    
    height = max_height if height > max_height
    width  = max_width if width > max_width

    image.crop("#{width}x#{height}+#{width_offset}+#{height_offset}")
  end
  
end