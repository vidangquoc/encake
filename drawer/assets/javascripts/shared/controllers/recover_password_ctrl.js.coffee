app.controller 'RecoverPasswordCtrl', ['$scope', '$injector', ($scope, $injector) ->

  $location     = $injector.get('$location')
  $state        = $injector.get('$state')
  $stateParams  = $injector.get('$stateParams')
  httpApi       = $injector.get('httpApi')
  flash         = $injector.get('flash')
  
  $scope.user = {email: $stateParams.email}
  
  $scope.submit = ()->
    
    $scope.recovering = true
    
    flash.dismiss(':all')
    
    httpApi.put("users/recover_password", email: $scope.user.email).then( ->
      
      $scope.recovering = false
      
      flash.next.info = 'Mật khẩu mới đã được gửi đến email của bạn.'
      
      $state.go('^.login', email: $scope.user.email)
      
    , (error)->          
      
      flash.error = error.data.message if error.status == 422 #Unprocessable Entity
      
      $scope.recovering = false
      
    )
  
  
]