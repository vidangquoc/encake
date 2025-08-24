app.controller 'LessonCtrl', ['$scope', '$stateParams', 'httpApi', ($scope, $stateParams, httpApi) ->
  
  httpApi.get('/lessons/' + $stateParams.lesson_id ).then (response)->
    
    $scope.lesson = response.data
        
]