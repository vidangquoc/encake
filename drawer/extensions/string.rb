class String
  
  def parse_date
    
    begin
      
      Date.send(self)
      
    rescue NoMethodError
            
      patern_method_map = {
        /^none$/ => 'parse_none',
        /^(\d+) (\w+) from (now|today)$/ => 'parse_number_of_units_from_now',
        /^(\d+) (\w+) ago$/ => 'parse_number_of_units_ago',
        /^the day after tomorrow$/ => 'parse_the_day_after_tomorrow'
      }
      
      patern_method_map.each do |patern, method|
        matches = gsub(/\s+/, ' ').strip.match patern        
        return send(method, matches) if matches
      end               
                   
      to_date
    
    end
    
  end
  
  def to_ascii_characters
    
    self.each_char.map { |char| (char.to_i + 97).chr }.join('')
    
  end
  
  
  private
  
  def parse_number_of_units_from_now(matches)      
    number = matches[1].to_i
    unit = matches[2]
    Date.today + number.send(unit)
  end
  
  def parse_number_of_units_ago(matches)
    number = matches[1].to_i
    unit = matches[2]
    Date.today - number.send(unit)
  end  
  
  def parse_the_day_after_tomorrow(matches)
    Date.today + 2.days
  end
  
  def parse_none(matches)
    nil
  end
  
end

class InvalidDateString < Exception
end