app.controller 'ConfirmFriendInvitationsCtl', ['$scope', '$http', '$location', 'flash', ($scope, $http, $location, flash) ->
  
  $http.get('invitations/stored_emails').then (response) ->
    
    if response.data? && response.data.length > 0
    
      $scope.emails = response.data
      
    else
      
      flash.next.info = "Không tìm thấy email nào trong danh sách email của bạn. Hãy nhập trực tiếp những email bạn muốn mời."
      
      $location.path('invite_friends_directly')
    
    
  $scope.confirm = ->
    
    selected_emails = (email.email for email in $scope.emails when email.selected? && email.selected)
      
    if selected_emails.length > 0
      
      $http.post('invitations/send_invitations', emails: selected_emails).then (response) ->
    
        flash.next.info = response.data.message
        
        $location.path('friends')
    
    else
      
      flash.error = "Hãy chọn ít nhất một email."
]