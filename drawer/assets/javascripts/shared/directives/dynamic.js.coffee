app.directive 'dynamic',[ '$compile', ($compile) ->
  
    restrict: 'A'
    
    replace: true
    
    link: (scope, element, attrs) ->
      
      scope.$watch attrs.dynamic, (html) ->
        
        element.html html
        
        $compile(element.contents()) scope

]