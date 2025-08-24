app.directive 'onOutsideClick',[ ->
  
    restrict: 'A'
    scope:
      onOutsideClick: '&'
    
    link: (scope, element, attrs) ->
      
      element.on "click", (event) ->
        
        event.preventDefault()
        event.stopPropagation()
        
      $(document).on "click.onOutsideClick", ->
        
        scope.$apply -> scope.onOutsideClick()
        
       scope.$on '$destroy', ->
        
        $(document).off "click.onOutsideClick"
        
]