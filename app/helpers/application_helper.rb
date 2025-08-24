module ApplicationHelper
  
  def yield_or(name, content = nil, &block)
    if content_for?(name)
      content_for(name)
    else
      block_given? ? capture(&block) : content
    end
  end
  
  def readable_domain_name
    %w{en cake.com}.map do |word|
      "<span style='margin-left:2px'>#{word}</span>"
    end
    .join('').html_safe
  end
  
  #def get_first_error_message(error_messages, key_orders)
  #  key_orders.each do |key|      
  #    if error_messages.any? {|error_key, messages| error_key == key.to_sym}
  #      return error_messages[key].first
  #    end
  #  end
  #end
  
  def template_file_paths
    
    template_path = Rails.root.join('app/views/templates/').to_s
    
    path_pairs = Dir["#{template_path}**/*"].select do |path|      
      File.file? path
    end
    .map do |path|
      template_id = "templates/#{path.sub(template_path, '').sub(/\..*$/, '')}.html"
      [template_id, path]
    end
    
    Hash[path_pairs]
    
  end
  
end
