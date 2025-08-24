app.controller 'PointsCtrl', ['$scope', '$injector', ($scope, $injector) ->
  
  httpApi     = $injector.get('httpApi')
  $location   = $injector.get('$location')
  localStorageService = $injector.get('localStorageService')
  platform    = $injector.get('platform')
  $timeout    = $injector.get('$timeout')
  flash       = $injector.get('flash')
  soundHandler  = $injector.get('soundHandler')
  Constants     = $injector.get('Constants')
  
  soundHandler.setup
    
      sound_path: Constants.api_endpoint + 'sounds/(sound_id)/(version)'  
  
  localStorageService.bind($scope, "search", {search_in: 'all', content: '', number_of_items: 20} )
  
  $scope.result = {}  
  
  if platform.is_mobile_app
    
    $scope.set_search_in = (search_in) ->
      
      $scope.search.search_in = search_in
      
      $scope.do_search()
      
  $scope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams)->
    
    if toState.name == 'logged.points' && (fromState.name == 'logged.add_point' || fromState.name == 'logged.edit_point')
      
      $timeout (-> $scope.do_search()), 400 #timeout for better transition from the previous views
      
  httpApi.get('points/types').then (response) ->
    
    $scope.point_types = response.data
  
  $scope.do_search = ->
    
    return if $scope.searching
    
    $scope.result.points = []
    
    $scope.search.page = 1
    
    $scope.there_are_more = true
    
    $scope.searching = true
    
    httpApi.get('points', { params: $scope.search}).then((response) ->
      
      $scope.there_are_more = (response.data.length == $scope.search.number_of_items)
      
      $scope.result.points = response.data
      
    ).finally -> $scope.searching = false
    
  $scope.load_more = ->
    
    if !$scope.searching && !$scope.loading_more && $scope.there_are_more
      
      $scope.search.page += 1
    
      $scope.loading_more = true
      
      httpApi.get('points', { params: $scope.search}).then((response) ->
        
        $scope.there_are_more = (response.data.length == $scope.search.number_of_items)
        
        $scope.result.points = $scope.result.points.concat(response.data)
        
        $scope.$broadcast('scroll.infiniteScrollComplete')
        
      ).finally -> $scope.loading_more = false
  
  $scope.add_point_to_bag = (point)->
    
    flash.dismiss(':all')
    
    $scope.adding_point = point
    
    httpApi.post('users/add_point_to_bag', {point_id: point.id}).then ->
      
      point.is_in_bag = true
      
      flash.info = "Đã thêm vào sổ từ"
      
    .finally -> $scope.adding_point = null
    
  $scope.remove_point_from_bag = (point)->
    
    flash.dismiss(':all')
    
    $scope.removing_point = point
    
    httpApi.put('users/deactivate_point_in_bag', point_id: point.id).then ->
      
      point.is_in_bag = false
      
      flash.info = "Đã loại khỏi sổ từ"
      
    .finally -> $scope.removing_point = null
    
  $scope.destroy = (point) ->
    
    flash.dismiss(':all')
    
    $scope.destroying_point = point
    
    httpApi.delete('points/' + point.id).then ->
      
      $scope.result.points.splice($scope.result.points.indexOf(point), 1)
      
      flash.info = "Đã xóa"
      
    .finally -> $scope.destroying_point = null
    
  $scope.edit = (point) -> $location.url('edit_point?point_id=' + point.id)
    
  $scope.add_new_point = -> $location.url('add_point')
  
  $scope.play_sound = (sound)->
    
    soundHandler.release_all_sounds(true)
    
    soundHandler.play_sound(sound) if sound?.has_data
    
  $scope.do_search()
  
]

