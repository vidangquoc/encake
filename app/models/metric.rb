class Metric < ActiveRecord::Base
  
  attr_accessor :conversion_rate, :active_users, :retention_rate
  attr_accessor :avarage_session_length, :avarage_first_session_length, :avarage_session_interval
  strip_attributes collapse_spaces: true
  
end

class << Metric
  
  def avarage_first_session_lengths(from_time, to_time, time_interval)
    
    group_id = create_and_insert_time_ranges(from_time, to_time, time_interval)
    
    sql = "
      SELECT start_time, end_time,
      AVG(  TIME_TO_SEC( TIMEDIFF(authentication_tokens.updated_at, authentication_tokens.created_at) ) ) AS avarage_first_session_length
      FROM
      (
        SELECT users.id AS user_id, metrics.start_time, metrics.end_time, MIN(authentication_tokens.created_at) AS created_at
        FROM metrics
        LEFT JOIN users ON users.created_at >= metrics.start_time AND users.created_at <= metrics.end_time
        LEFT JOIN authentication_tokens ON users.id = authentication_tokens.user_id
        WHERE  group_id = #{group_id}
        GROUP BY users.id, metrics.start_time, metrics.end_time
      ) AS first_sessions
      LEFT JOIN authentication_tokens ON first_sessions.user_id = authentication_tokens.user_id AND first_sessions.created_at = authentication_tokens.created_at
      GROUP BY start_time, end_time
      ORDER BY start_time
    "
          
    metrics = Metric.find_by_sql(sql)
    
    Metric.where(group_id: group_id).delete_all
    
    metrics.each do |metric|
      metric.avarage_first_session_length = metric.attributes['avarage_first_session_length'].to_i
    end
    
    metrics
    
  end
  
  def avarage_session_intervals(from_time, to_time, time_interval)
    
    group_id = create_and_insert_time_ranges(from_time, to_time, time_interval)
    
    sql = "
      SELECT start_time, end_time, AVG(session_interval) AS avarage_session_interval
      FROM
      (
        SELECT metrics.start_time, metrics.end_time,
        TIME_TO_SEC( TIMEDIFF( MIN(authentication_tokens.created_at), users.created_at ) ) AS session_interval
        FROM metrics
        LEFT JOIN users ON users.created_at >= metrics.start_time AND users.created_at <= metrics.end_time
        LEFT JOIN authentication_tokens ON users.id = authentication_tokens.user_id
        WHERE 
        group_id = #{group_id}
        GROUP BY users.id, users.created_at, metrics.start_time, metrics.end_time
      ) AS session_intervals
      GROUP BY start_time, end_time
      ORDER BY start_time
    "
          
    metrics = Metric.find_by_sql(sql)
    
    Metric.where(group_id: group_id).delete_all
    
    metrics.each do |metric|
      metric.avarage_session_interval = metric.attributes['avarage_session_interval'].to_i
    end
    
    metrics
    
  end
  
  def retention_rates(start_of_registering_time, end_of_registering_time, start_time, end_time, interval)
    
    registration_num = User.where(['created_at >= ? AND created_at <= ?', start_of_registering_time, end_of_registering_time]).count
    
    retention_rate_metrics = active_users(start_time, end_time, interval)
    
    retention_rate_metrics.each do |metric|
      metric.retention_rate = (registration_num == 0 ? 0 : (metric.active_users*100/registration_num).round )
    end
        
  end
  
  def avarage_session_lengths(start_time, end_time, interval)
    
    select = "AVG( TIME_TO_SEC( TIMEDIFF(authentication_tokens.updated_at, authentication_tokens.created_at) ) ) AS session_length";
    
    join_conditions = "authentication_tokens.user_type='active'"
    
    avarage_session_length_metrics = execute_metric_query(start_time, end_time, interval, select, join_conditions)
    
    avarage_session_length_metrics.each do |metric|
      metric.avarage_session_length = metric.attributes['session_length']
      metric.avarage_session_length = 0 if metric.avarage_session_length.nil?
    end
    
    avarage_session_length_metrics
    
  end
  
  def active_users(start_time, end_time, interval)
    
    select = "COUNT(DISTINCT authentication_tokens.user_id) AS active_users"
    
    join_conditions = "authentication_tokens.user_type='active'"
    
    active_users_metrics = execute_metric_query(start_time, end_time, interval, select, join_conditions)
    
    active_users_metrics.each do |metric|
      metric.active_users = metric.attributes['active_users']
    end
    
    active_users_metrics
    
  end
  
  def conversion_rates(start_time, end_time, interval = :week)
    
    select = "
      SUM(IF(authentication_tokens.user_type='anonymous', 1, 0)) AS anonymous,
      SUM(IF(authentication_tokens.user_type='just_registered', 1, 0)) AS registered
    "

    rate_metrics = execute_metric_query(start_time, end_time, interval, select)
    
    rate_metrics.each do |metric|
      registered = metric.attributes['registered'].to_i
      anonymous = metric.attributes['anonymous'].to_i 
      total =  registered + anonymous
      metric.conversion_rate = (total == 0 ? 0 : (registered*100/total).round )
    end
    
    rate_metrics
    
  end
  
  def create_time_ranges(start_time, end_time, interval)
    if interval == :day
      create_day_ranges(start_time, end_time)
    elsif interval == :week
      create_week_ranges(start_time, end_time)
    elsif interval == :month
      create_month_ranges(start_time, end_time)
    else
      raise Exception.new("Invalid time interval")
    end
  end
  
  private
  
  def execute_metric_query(start_time, end_time, interval, select, join_conditions = nil, conditions = nil, joins = nil)
    
    group_id = create_and_insert_time_ranges(start_time, end_time, interval)
    
    sql = " SELECT metrics.start_time, metrics.end_time, #{select}
      FROM metrics
      LEFT JOIN authentication_tokens
      ON authentication_tokens.created_at >= metrics.start_time
      AND authentication_tokens.created_at <= metrics.end_time
      #{join_conditions ? "AND #{join_conditions}" : ''}
      #{joins ? "JOIN #{joins}" : ''}
      WHERE group_id = #{group_id}
      #{conditions ? "AND #{conditions}" : ''}
      GROUP BY metrics.start_time, metrics.end_time
      ORDER BY metrics.start_time 
    "
    
    metrics = Metric.find_by_sql(sql)
    
    Metric.where(group_id: group_id).delete_all
    
    metrics
    
  end
  
  def create_and_insert_time_ranges(start_time, end_time, interval)
    
    time_ranges = create_time_ranges(start_time, end_time, interval)
  
    group_id = rand_group_id
    
    time_ranges.each do |range|
      create(group_id: group_id, start_time: range.first, end_time: range.last)
    end
    
    group_id;
    
  end
  
  def create_month_ranges(start_time, end_time)
    
    ranges = []
    
    (start_time..end_time).each do |time|
      
      start_range = time.beginning_of_month
      end_range = time.end_of_month
      
      start_range = start_time if start_range < start_time
      end_range = end_time if end_range > end_time
      
      ranges << [start_range, end_range]
      
    end
    
    ranges.uniq
    
  end
  
  def create_week_ranges(start_time, end_time)
    
    ranges = []
    
    (start_time..end_time).each do |time|
      
      start_range = time.beginning_of_week
      end_range = time.end_of_week
      
      start_range = start_time if start_range < start_time
      end_range = end_time if end_range > end_time
      
      ranges << [start_range, end_range]
      
    end
    
    ranges.uniq
    
  end
  
  def create_day_ranges(start_time, end_time)
    
    ranges = []
    
    (start_time..end_time).each do |time|
      
      ranges << [time.beginning_of_day, time.end_of_day]
      
    end
    
    ranges
    
  end
  
  def rand_group_id
    rand(100000000000000)
  end
  
end