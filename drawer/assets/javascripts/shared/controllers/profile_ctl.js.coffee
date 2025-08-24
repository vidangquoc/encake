app.controller 'ProfileCtrl', ['$scope', '$injector', ($scope, $injector) ->
  
  $rootScope  = $injector.get('$rootScope')
  flash       = $injector.get('flash')
  httpApi     = $injector.get('httpApi')
  
  httpApi.get('users/' + $rootScope.current_user.id).then (response) ->
    
    $scope.user = response.data
  
  $scope.update = (formData)->
    
    flash.dismiss(':all')
    
    $scope.updating = true
    
    httpApi.upload({
      method: 'PUT',
      url: "users/update_profile",
      data: user: $scope.user
    }).then( (response) ->
      
      auth_token = $rootScope.current_user.auth_token
      
      $scope.updating = false
      $scope.user = response.data.current_user
      $rootScope.current_user = $scope.user
      $rootScope.current_user.auth_token = auth_token
      
      flash.info = response.data.message
      
    , (error)->
      $scope.updating = false
      $scope.user.validation_messages = error.data if error.status == 422 #Unprocessable Entity
    )  
  
]