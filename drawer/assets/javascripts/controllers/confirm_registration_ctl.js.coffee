app.controller 'ConfirmRegistrationCtl', ['$scope', '$http', '$location', '$routeParams', 'flash', 'Auth', ($scope, $http, $location, $routeParams, flash, Auth) ->
  
  $http.post('users/confirm_registration',
             email: $routeParams.email,
             confirmation_hash: $routeParams.confirmation_hash
  ).then (response) ->
    
    #Call Auth.login to apply logged-in status on client side
    Auth.login().then ->
    
      flash.next.info = response.data.message
      
      $location.url('/')
    
  , (error) ->
    
    flash.error = error.data.message if error.status == 422
    
]