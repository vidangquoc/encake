app.directive 'focusBy',[ '$compile', '$timeout', ($compile, $timeout) ->
  
    restrict: 'A'
    
    scope:
      focusBy: '='
    
    link: (scope, element) ->          
      
      scope.$watch 'focusBy', ->
        
        $timeout -> element.focus()
                
]