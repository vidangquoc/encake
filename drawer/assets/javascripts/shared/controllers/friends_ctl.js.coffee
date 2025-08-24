app.controller 'FriendsCtrl', ['$scope', 'httpApi', ($scope, httpApi) ->
  
  httpApi.get('users/friends').then (response) ->
    $scope.friends = response.data
 
]