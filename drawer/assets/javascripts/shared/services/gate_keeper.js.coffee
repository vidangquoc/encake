app.factory 'gateKeeper', ['$injector', ($injector) ->
  
  $q        = $injector.get('$q')
  $timeout  = $injector.get('$timeout')
  $state    = $injector.get('$state')
  authentication  = $injector.get('authentication')
  
  class GateKeeper
    
    check: ()->
      
      deferred = $q.defer()
                  
      authentication.current_user().then (user)-> #if user has logged in
          
          deferred.resolve() 
          
        , -> # if user has not logged in
          
          $timeout -> $state.go('anonymous.login')
          
          deferred.reject()
          
      deferred.promise
      
    check_anonymous: ->
      
      deferred = $q.defer()
                  
      authentication.request_anonymous_token().then ->
          
          deferred.resolve() 
          
        , -> # failed to request an anonymous token
          
          deferred.resolve() # still resolve

      deferred.promise
      
  new GateKeeper()
  
]