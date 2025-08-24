module Cache
  class Cleaner
  end
end

class << Cache::Cleaner
  
  def clear_index
    cache_file = Rails.root.join('public','index.html')
    File.delete(cache_file) if File.exist? cache_file
  end
  
  def clear_point_types
    cache_file = Rails.root.join('public','points', 'types.json')
    File.delete(cache_file) if File.exist? cache_file
  end
  
end