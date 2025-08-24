#class A
#  @say: ->
#    console.log 'hello'
#  
#  say: ->
#    console.log 'say from instance'
#
#class A extends A
#  @hi: ->
#    console.log('hi')
#  
#  hi: ->
#    console.log 'hi from instance'
#
##A.hi
#
#A.say()
#(new A()).say()
#A.hi()
#(new A()).hi()

class IndexTracker2
  
  turn: 1  
  point_id: 1  
  reminded_words: {}  
  points:[]
  
  constructor: (@points) ->  
  
  next: ->
                           
    index = (index for point, index in @points when point.id is @point_id)[0] + 1
    ( index = 0; @turn += 1 ) if index == @points.length
       
    while true
                                  
      for i in [index...@points.length]
        ( index = i; break ) if @points[i].id in this.active_ids()
                
      if  @points[index].id in this.active_ids()
        break
      else
        @turn += 1; index = 0
    
    @point_id = @points[index].id       
    
    this.current()               
  
        
  previous: ->
  
    index = current_index = this.current_index()       
    
    while index > 0         
      
      index -= 1
      
      break if @points[index].id in this.active_ids()
                                
    index = current_index if @points[index].id not in this.active_ids()
              
    @point_id = @points[index].id
    
    this.current();
    
        
  current: -> @point_id
  
  
  current_index: -> (index for point, index in @points when point.id is @point_id)[0]
    
  
  record_reminding: ->
    
    word_id = this.current()
               
    if @turn not of @reminded_words
      @reminded_words[@turn] = []
    
    if word_id not in @reminded_words[@turn.toString()]
    
      @reminded_words[@turn.toString()].push(word_id)
  
  
  active_ids: ->
  
    active_ids =  @reminded_words[(@turn - 1).toString()] 
          
    active_ids = (point.id for point in @points) if not active_ids?
          
    active_ids       
  
  
  get_reminded_times: ->
    
    reminded_times = {}       
    
    for turn, word_ids of @reminded_words
      for id in word_ids
        if ( id of reminded_times ) then reminded_times[id.toString()] += 1 else reminded_times[id] = 1          
      
    reminded_times
                               
  
  log_next: ->
    console.log this.next()
  
  log_previous: ->
    console.log this.previous()
    

      
points = [
            {id: 1, content: 'Point 1'}
            {id: 2, content: 'Point 2'}
            {id: 3, content: 'Point 3'}
            {id: 4, content: 'Point 4'}
            {id: 5, content: 'Point 5'}                       
         ]   

tracker = new IndexTracker2(points)

test_next = ->
  console.log "test next()"
  console.log tracker.current()
  tracker.log_next(); tracker.record_reminding()
  tracker.log_next(); tracker.record_reminding()
  tracker.log_next();
  tracker.log_next(); tracker.record_reminding()
  tracker.log_next();
  tracker.log_next();
  tracker.log_next();
  tracker.log_next();
  

#test_next()    

test_previous = ->
  console.log "test previous()"
  console.log( tracker.current() )
  tracker.log_next(); tracker.record_reminding()     
  tracker.log_next(); tracker.record_reminding()   
  tracker.log_next(); tracker.record_reminding()
  tracker.log_next()
  tracker.log_next()
  tracker.log_next()
  tracker.log_next()
  tracker.log_previous()
  tracker.log_previous()
  tracker.log_previous()
  
#test_previous()

test_get_reminded_times = ->
  console.log( tracker.current() )
  tracker.log_next(); tracker.record_reminding()     
  tracker.log_next(); tracker.record_reminding()   
  tracker.log_next(); tracker.record_reminding()
  tracker.log_next()
  tracker.log_next()
  tracker.log_next(); tracker.record_reminding()
  tracker.log_next(); tracker.record_reminding()
  tracker.log_next();
  tracker.log_next();
  tracker.log_next();
  console.log(tracker.get_reminded_times())
  

#test_get_reminded_times()


