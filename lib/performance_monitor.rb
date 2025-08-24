class PerformanceMonitor
  
  attr_reader :logging_queries
  
  def subscribe
    ActiveSupport::Notifications.subscribe "sql.active_record" do |name, start, finish, id, payload|
      monitor_sql(name, start, finish, id, payload)
    end
    ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
      monitor_request(name, start, finish, id, payload)
    end
  end
  
  private
  
  def monitor_sql(name, start, finish, id, payload)
      
      duration = (finish - start) * 1000      

      if duration > Constants.slow_db_query_threshold && !logging_queries.include?(id)
        
        logging_queries << id
        
        SlowQuery.create(duration: duration, query: payload[:sql])
        
        logging_queries.delete(id)
        
      end
    
  end
  
  def monitor_request(name, start, finish, id, payload)
    
    duration = (finish - start) * 1000
    
    if duration > Constants.slow_request_threshold
      
      SlowRequest.create(
        controller: payload[:controller],
        action: payload[:action],
        duration: duration,
        db_runtime: payload[:db_runtime],
        view_runtime: payload[:view_runtime],
        params: payload[:params].inspect
      )
      
    end
    
  end
  
  def logging_queries
    @logging_queries ||= []
  end
  
end