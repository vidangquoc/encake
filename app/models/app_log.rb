class AppLog < ActiveRecord::Base
  strip_attributes collapse_spaces: true
end

class << AppLog
  
  def log(content, type = nil, device = nil)
    
    type = type || 'Unknown'
    device = device || 'Unknown'
    
    create(
      log_type: type,
      content: content,
      device: device
    )
    
  end
  
end
