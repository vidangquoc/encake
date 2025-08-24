app.controller 'RegisterCtrl', [ '$scope', '$state', 'httpApi', 'flash', ($scope, $state, httpApi, flash)  ->
  
  $scope.user = {last_name: ''}
  
  $scope.submit = ()->
    
    $scope.registering = true
    
    flash.dismiss(':all')
    
    httpApi.post("users", user: $scope.user).then( ->
      
      flash.next.info = 'Đăng kí thành công, thông tin tài khoản đã được gửi đến email của bạn.'
      
      $state.go('^.login', email: $scope.user.email)
      
      reset()
      
    , (error)->          
      
      $scope.registering = false
      
      $scope.user.validation_messages = error.data if error.status == 422 #Unprocessable Entity
      
    )
  
  reset = ()->
    
    $scope.registering = false
    
    $scope.user = {last_name: ''}
        
]  