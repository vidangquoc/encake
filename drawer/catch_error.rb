begin
  raise "ABC"
rescue Exception => ex
  {error_message: ex.message, error_trace: ex.backtrace}.to_json
end