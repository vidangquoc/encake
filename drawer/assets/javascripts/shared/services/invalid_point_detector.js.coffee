app.factory 'invalidPointDetector', ['serverLogger', (serverLogger) ->
  
  class InvalidPointDetector
    
    detect: (point) ->
      
      message = ""
    
      if ! point?
        message += "Current point is undefined or null"
      else
        
        if !point.reviewed_skill?
          message += ' no reviewed skill'
        
        if point.is_valid
        
          if ! point.sound?
            message += " no sound."
          
          if ! point.main_example?
            message += " no main example."
          else if ! point.main_example.sound?
            message += " main example has no sound"
          
          if ! point.question?
            message += " no question."
          else
            if point.question.answers.length <= 1
              message += " question has less than two answers."        
            if ! point.question.right_answer_id?
              message += " question has no specified answer"
          
      if message != ""
        
        message = "Invalid point {id: "  + point?.id +  ", content: " + point?.content + "}." + message
        
        serverLogger.log(message)
  
  
  new InvalidPointDetector()
  
]  