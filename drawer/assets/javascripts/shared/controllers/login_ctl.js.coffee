app.controller 'LoginCtrl', ['$scope', '$injector', ($scope, $injector) ->
  
  $rootScope = $injector.get('$rootScope')
  $state  = $injector.get('$state')
  $stateParams = $injector.get('$stateParams')
  #Auth    = $injector.get('Auth')
  authentication = $injector.get('authentication')
  flash   = $injector.get('flash')
  serverLogger = $injector.get('serverLogger')
  
  $scope.user = {email: $stateParams.email, password: ''}
  
  $scope.logging = false
  
  $scope.login = ->
    
    flash.dismiss()
    
    $scope.logging = true
    
    authentication.login($scope.user).then (user)->
      
      $state.go('logged.review')
      
    .then( (->),(error) ->
      
      reset()
      
      flash.error = error.data.message if error.status == 422 #Unprocessable entity
    )
  
  reset = (all) ->
    
    all = all || false
    
    $scope.logging = false
      
    $scope.user.password = ''
    
    $scope.user.email = '' if all
       
]