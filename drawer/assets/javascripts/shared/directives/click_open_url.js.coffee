app.directive 'clickToOpenUrl',[ '$window', ($window) ->
  
    restrict: 'A'
    scope:
      clickToOpenUrl: '@'
    
    link: (scope, element, attrs) ->
      
      element.on 'click', ->
        
        $window.open(scope.clickToOpenUrl)
          
]