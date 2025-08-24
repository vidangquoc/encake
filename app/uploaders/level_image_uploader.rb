# encoding: utf-8

class LevelImageUploader < BaseUploader
  
  version :large do
    process :resize_to_fit => [100,100]
  end
  
  version :thumb do
    process :resize_to_fit => [50,50]
  end
   
  version :tiny do
    process :resize_to_fit => [20,20]
  end
      
end