class Log
end

class << Log
    
  def method_missing(method_name, *args, &block)
    
    singleton_class.class_eval do
         
      define_method method_name do |message, dir = ''|
        
        if dir != '' && ! Dir.exists?( Rails.root.join('log', dir) )
          Dir.mkdir Rails.root.join('log', dir)
        end
        
        File.open(Rails.root.join('log', dir, "#{method_name}.log"), 'a') do |file|
          if !message.instance_of? String
            message = message.inspect
          end
          file.puts(message)
        end
        
      end
      
    end
    
    send method_name, *args
    
  end
  
  def start_tracking_time()
    @marks = []
  end
  
  def mark(mark_name)
    @marks.push([mark_name, (Time.now.to_f.round(3)*1000).to_i])
  end
  
  def end_tracking_time(file_name)
    stat = ""
    (1 ... @marks.length).each do |index|
      previous_mark = @marks[index - 1]
      mark = @marks[index]
      if !previous_mark.nil?
        stat << "#{previous_mark[0]} -> #{mark[0]} : #{mark[1] - previous_mark[1]} \n"
      end      
    end
    File.open(Rails.root.join('log', "#{file_name}.log"), 'a') do |file|
      file.puts(stat)
      file.puts("")
      file.puts("")
    end
  end
  
  private
  
  def singleton_class
    class << self; self; end
  end
  
end
