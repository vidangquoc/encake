app.controller 'InviteFriendsDirectlyCtrl', ['$scope', '$http', '$location', 'flash', ($scope, $http, $location, flash) ->
  
  $scope.submit = ->
    
    flash.dismiss(':all')
    
    $http.post('invitations/send_direct_invitations', invited_emails: $scope.invited_emails).then (response) ->
      
      if response.data.invalid_emails.length > 0
        
        flash.error = response.data.message
        
        $scope.invited_emails = response.data.invalid_emails.join("\n")
        
      else
        
        flash.next.info = response.data.message
        
        $location.path('friends')
        
    , (error) ->
      
      flash.error = error.data.message if error.status == 422 #unprocessable entity
  
]