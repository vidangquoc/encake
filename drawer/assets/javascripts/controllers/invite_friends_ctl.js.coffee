app.controller 'InviteFriendsCtrl', ['$scope', '$http', '$window', '$location', ($scope, $http, $window, $location) ->
  
  $http.get('invitations/importer').then (response) ->
    
    if response.data.importer?
      $window.location.href = "/contacts/" + response.data.importer
    else
      $location.path("invite_friends_directly")
  
]