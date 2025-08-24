class Array   
  
  def to_hashes(*keys)
    
    if keys[0].class == Hash           
      
      headers        = self[0].map{ |header| header.squeeze(' ').strip.downcase }          
  
      headers_keys   = Hash[ keys[0].map{ |header, key| [header.squeeze(' ').strip.downcase, key] } ]
                 
      self[1...self.count].inject([]) do |returned_hashes, array|
        hash = {}
        array.each_with_index do |value, index|
          raise HeaderMappingException, "cannot find mapping for '#{self[0][index]}'" if headers_keys[headers[index]].nil?      
          hash[ headers_keys[headers[index]] ] = value           
        end  
        returned_hashes << hash
      end
    
    else
    
      self.inject([]) do |returned_hashes, array|
        hash = {}
        array.each_with_index {|value, index| hash[ keys[index] ] = value }
        returned_hashes << hash
      end
    
    end
    
  end
  
  def extract_hashes(*keys, &block)
        
    self.inject([]) do |returned_hashes, hash|
      sub_hash = {}
      hash.each_pair{|key, value| sub_hash[key] = value if keys.include?(key) }
      yield(sub_hash) if block_given?
      returned_hashes << sub_hash
    end
    
  end
  
  def extract_hash_values(key)
    
    self.map{ |hash| hash[key] }
    
  end
  
  def change_hash_values(key, &block)
    
    self.each do |hash|
      hash[key] = yield( hash[key] )
    end
    
  end
   
end

class HeaderMappingException < Exception
end