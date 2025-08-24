class PointImage < ActiveRecord::Base
  
  serialize :cropping_data, Hash
  
  mount_uploader :image, PointImageUploader
  
  validates_presence_of :point_id, :image
  
  def url
    image.url
  end
  
  def small_url
    image.small.url
  end
  
  def medium_url
    image.medium.url
  end
  
  def big_url
    image.big.url
  end
  
  def cropping_data_available?
    ! cropping_data.nil? && ! cropping_data[:x].nil?
  end
  
end
