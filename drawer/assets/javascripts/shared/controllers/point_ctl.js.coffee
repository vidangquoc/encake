app.controller 'PointCtrl', ['$scope', '$injector', ($scope, $injector) ->
  
  httpApi   = $injector.get('httpApi')
  flash     = $injector.get('flash')
  $stateParams = $injector.get('$stateParams')
  
  point_id = $stateParams.point_id
  $scope.edit_mode = point_id?
  
  if $scope.edit_mode
    
    httpApi.get('points/' + point_id + '/edit').then (response)->
      
      $scope.point = response.data
      
      $scope.point.main_example_attributes = {}
      
      $scope.point.main_example_attributes.content = $scope.point.main_example.content
      
      $scope.point.main_example_attributes.meaning = $scope.point.main_example.meaning
      
  else
    
    $scope.point = {main_example_attributes: {content: ''}}

  httpApi.get('points/types').then (response) -> $scope.point_types = response.data
  
  $scope.submit = ->
    
    flash.dismiss(':all')
    
    $scope.saving = true
    
    url =  "points/" + if $scope.edit_mode then point_id else ''
    
    method = if $scope.edit_mode then 'put' else 'post'
    
    httpApi(
      url: url,
      method: method;
      data: {point: $scope.point}
    ).then( (response) ->
      
      flash.info = response.data.message
      
      reset() if !$scope.edit_mode
      
    , (error)->
      
      $scope.point.validation_messages = error.data if error.status == 422 #Unprocessable Entity
      
    ).finally ->
      
      $scope.saving = false
    
    
  reset = ->
    
    $scope.point = {content: '', main_example_attributes: {content: ''}}
    
    $scope.focus_content = Math.random()
    
]    