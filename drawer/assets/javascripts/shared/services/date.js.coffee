app.factory 'date', [->
  
  current_timestamp: -> Date.now()
    
  add_days: (timestamp, days) ->
    
    new Date(timestamp + days * 24*60*60*1000).getTime()
    
]