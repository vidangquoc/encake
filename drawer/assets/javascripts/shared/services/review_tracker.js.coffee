app.factory 'reviewTracker', ->
  
  class ReviewTracker
  
    constructor: ->
      
      @reset({points: []})
    
    reset: (data,end_turn)->
      
      @points = data.points
                
      @turn = data.turn || 1
    
      @big_turn = data.big_turn || 1          
      
      @reminded_indexes = data.reminded_indexes || {}
      
      @end_turn = end_turn || null
      
      @current_index = data.current_index || 0
      
    data: ->
      
      point_ids = (point.id for point in @points)
       
      skills = ([point.id, point.reviewed_skill]  for point in @points)
      
      {point_ids: point_ids, skills: skills, turn: @turn, big_turn: @big_turn, reminded_indexes: @reminded_indexes, current_index: @current_index}
          
    current_point: -> @points[@current_index]
      
    next_point: ->
      
      previous_point = @current_point()
      
      previous_big_turn = @big_turn
      
      @_next()
      
      @_next() if @current_point().id == previous_point.id && @current_point().reviewed_skill == previous_point.reviewed_skill && @big_turn == previous_big_turn #skip to next point if the current point is the previous point in the same big turn
        
      @current_point()
    
    previous_point: -> @_previous(); @current_point()
    
    record_reminding: ->
      
      @reminded_indexes[@turn] = [] if @turn not of @reminded_indexes    
          
      @reminded_indexes[@turn].push(@current_index) if @current_index not in @reminded_indexes[@turn]
      
    clear_reminding: ->
      
      if @reminded_indexes[@turn]?
        
        @reminded_indexes[@turn] = (index for index in @reminded_indexes[@turn] when index != @current_index)
          
    reminded_times: ->
      
      reminded_times = {}
      
      for turn, indexes of @reminded_indexes
      
        for index in indexes
          
          point = @points[index]
          
          key = point.id + "---" + point.reviewed_skill + (if point.skill_id? then "---" +  point.skill_id else "")
          
          if reminded_times[key]?
            reminded_times[key] += 1
          else
            reminded_times[key] = 1
          
      for point in @points
        
        key = point.id + "---" + point.reviewed_skill + (if point.skill_id? then "---" +  point.skill_id else "")
        
        reminded_times[key] = 0 if !reminded_times[key]?
      
      reminded_times_arr = []
      
      for key, times of reminded_times
        
        splits = key.split('---')
        
        point_id = parseInt(splits[0])
        reviewed_skill = splits[1]
        skill_id = parseInt(splits[2])
        
        reminded_times_arr.push({point_id: point_id, skill_symbol: reviewed_skill, skill_id: skill_id, reminded_times: times})
        
      reminded_times_arr
      
    point_count: -> @points.length
    
    index_of_current_point: -> @current_index
    
    progress: ->
      
      total = @points.length
      
      active_indexes = @_active_indexes()
      
      number_of_reminded_indexes = if @reminded_indexes[@turn] then @reminded_indexes[@turn].length else 0
      
      passed = (total - active_indexes.length) + (active_indexes.indexOf(@current_index) - number_of_reminded_indexes)  
      
      passed*100/total
    
    _next: ->
      
      index = @current_index + 1
      
      active_indexes = @_active_indexes()
      
      while true
                                    
        for i in [index...@points.length]
        
          ( index = i; break ) if i in active_indexes
                  
        if  index < @points.length && index in active_indexes
        
          break
          
        else
          
          if !@reminded_indexes[@turn]? || @reminded_indexes[@turn].length == 0
            
            @end_turn @big_turn if @end_turn?
            
            @big_turn += 1 
        
          @turn += 1; index = 0;
          
          active_indexes = @_active_indexes()
          
      @current_index = index
          
    _previous: ->
    
      index = @current_index
      
      active_indexes = @_active_indexes()
      
      while index > 0  
        
        index -= 1
        
        if index in active_indexes
        
          @current_index = index
          
          break 
    
    _active_indexes: ->
      
      active_indexes =  @reminded_indexes[(@turn - 1).toString()]
      
      active_indexes = (index for point, index in @points) if not active_indexes?
            
      active_indexes
                                      
  new ReviewTracker()