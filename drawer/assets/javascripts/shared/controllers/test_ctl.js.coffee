app.controller 'TestCtrl', ['$scope', '$injector', ($scope, $injector) ->
  
  $http = $injector.get('$http')
  $rootScope = $injector.get('$rootScope')
  $timeout = $injector.get('$timeout')
  invalidPointDetector = $injector.get('invalidPointDetector')
  exampleAlternativeParser = $injector.get('exampleAlternativeParser')
  authentication = $injector.get('authentication')
  httpApi = $injector.get('httpApi')
  serverLoger = $injector.get('serverLogger')
  
  $scope.create_failed_request = ->
    
    httpApi.post('wrong_url', {a: 1, b:2}, {abc: 123})
  
  $scope.log_to_server = -> serverLoger.log("A message " + Math.random())
  
  $scope.action_data = {a: 'a value', b: 'another value'}
  
  $scope.set_validation_messages = ->
    
    $scope.validation_messages = {first_name: ["It is required"]}
  
  $scope.login = ->
    
    authentication.login({email: 'dangquocvi@hotmail.com', password: 'vidaica'}).then( (user) ->
      console.log user
      $rootScope.current_user = user
    , (error) ->
      console.log error.data
    )
    
  $scope.logout = ->
    
    authentication.logout().then( ->
      console.log "Already out!"
    , (error) ->
      console.log error
    )
    
  $scope.log_current_user = ->
    
    authentication.current_user().then( (user)->
      console.log user
    , (error)->
      console.log error
    )
      
  #console.log exampleAlternativeParser.parse("Ta la {dai | ca | ta} dai ca la {ta | dai | ca}")
  #console.log exampleAlternativeParser.parse("Ta la dai ca")
  
  $scope.show_loader = ->
    $scope.loader_shown = true
  
  $scope.hide_loader = ->
    $scope.loader_shown = false
    
  $scope.throw_error = ->
    throw new Error("An Error")
  
  $scope.detect_invalid_point = =>
    invalidPointDetector.detect({})
    
  $scope.fire_an_ajax_request = ->
    
    $scope.firing_request = true
    
    $http.get('/invalid_url').then( (response) ->
      console.log response
    , (error) ->
      console.log error
    ).finally(->
      $scope.firing_request = false
    )
    
  $scope.doRefresh = ->
    console.log('refreshing...')
    $timeout( ( -> $scope.$broadcast('scroll.refreshComplete') ), 2000)
  
  $scope.source = "Are you a student? I ha.ve $20000. Let's go"
  $scope.dests = ["are you an student? I have $20,000. Lets go."]
  
  #$scope.dest = "I am a doctor, she is a architect Are you an student?"  
  
  $scope.test = {}
    
  $scope.test.s_model = 'AAA'
  
  $scope.content = "I love her more than {...} can say"
  
  $scope.answer = 'AA'
  
]