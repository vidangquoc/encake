app.directive 'stopPropagatingOfBackwardAndForwardKeysKeyupEvent', [ ->
  
    restrict: 'A'
    
    link: (scope, element) ->
      
      element.on "keyup", (event) ->
        
        val = element.val()
        
        if val != ''
          
          if event.keyCode == 37 || event.keyCode == 39 #back and forward keys
            
            event.preventDefault()
            
            event.stopPropagation()
      
      scope.$on "$destroy", -> element.off "keyup"
      
]