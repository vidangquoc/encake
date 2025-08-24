app.directive 'shake',[ ->
  
    restrict: 'A'
    
    scope:
      shake: '='
    
    link: (scope, element, attrs) ->
      
      scope.$watch 'shake', (value) ->
        
        if value
          
          element.effect('shake')
          
          scope.shake = false

]