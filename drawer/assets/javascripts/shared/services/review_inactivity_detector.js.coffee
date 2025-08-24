app.factory 'reviewInactivityDetector', ['$injector', ($injector)->
  
  $interval       = $injector.get('$interval')
  date            = $injector.get('date')
  
  class ReviewInactivityDetector
  
    last_active_at: date.current_timestamp()
    interval: null
    callback: null
    
    start: (callback)->
      
      @callback = callback
      
      if !interval?
        
        @interval = $interval =>
          @detect_inactivity()
        , 1000
        
    
    track_last_activitiy: ->
      
      @last_active_at = date.current_timestamp()
      
    detect_inactivity: ->
      
      if date.current_timestamp() - @last_active_at > 120*1000 # 2 minutes
        
        @last_active_at = date.current_timestamp()
        
        @callback() if @callback?
        
    stop: ->
      
      $interval.cancel(@interval)
      
      @interval = null
      
      @callback = null
      
  new ReviewInactivityDetector()        
    
]