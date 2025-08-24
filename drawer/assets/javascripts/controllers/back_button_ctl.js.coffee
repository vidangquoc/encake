app.controller 'BackButtonCtrl', ['$scope', '$injector', ($scope, $injector) ->

  $rootScope = $injector.get('$rootScope')
  
  $stateParams = $injector.get('$stateParams')
  
  $window = $injector.get('$window')
  
  $rootScope.show_back = false
  
  $rootScope.$on '$stateChangeSuccess', ->
    
    $rootScope.show_back = $stateParams.show_back?
    
  $scope.go_back = -> $window.history.back();
  
]