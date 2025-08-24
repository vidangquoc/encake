app.directive 'tooltip', [ ->
  
    restrict: 'A'
    
    link: (scope, element) ->
      
      element.tooltip()      
    
]