app.directive 'goToState',[ '$state', ($state) ->
  
    restrict: 'A'
    scope:
      goToState: '@'
      toStateParams: '@'
    
    link: (scope, element, attrs) ->
      
      element.on 'click', ->
        
        $state.go(scope.goToState, angular.fromJson(scope.toStateParams) )
          
]