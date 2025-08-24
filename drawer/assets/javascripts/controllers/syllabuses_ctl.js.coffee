app.controller 'SyllabusesCtl', ['$scope', '$http', ($scope, $http) ->
  
  $http.get('syllabuses').then (response) ->
    $scope.syllabuses = response.data
  
];