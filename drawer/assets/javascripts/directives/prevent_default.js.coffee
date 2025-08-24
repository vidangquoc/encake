app.directive 'preventDefaults', [ ->
  
    restrict: 'A'
    
    link: (scope, element, attrs) ->
      
      element.off(attrs.preventDefaults).on attrs.preventDefaults, (event) -> event.preventDefault()
      
      scope.$on "$destroy", -> element.off(attrs.preventDefaults)
      
]