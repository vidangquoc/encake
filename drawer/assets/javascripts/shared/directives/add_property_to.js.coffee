app.directive 'addPropertyTo',[ ->
  
  restrict: 'A'
  scope:
    target: '=addPropertyTo'
  
  link: (scope, element, attrs) ->
    
    scope.target = {} if !scope.target?
      
    scope.target[attrs.propertyName] = attrs.propertyValue
    
]