app.factory 'authentication', ['$injector', ($injector) ->
  
  $q          = $injector.get('$q')
  $rootScope  = $injector.get('$rootScope')
  httpApi     = $injector.get('httpApi')
  localStorageService   = $injector.get('localStorageService')
  
  class Authentication
  
    login: (credentials)->
      
      deferred = $q.defer()
                  
      httpApi.post('sessions', user: credentials).then (response) => #valid login
        
        user = response.data
        
        @_set_current_user(user)
        
        deferred.resolve(user)
        
      , (error)-> # invalid login
        
        deferred.reject(error)

      deferred.promise
      
    logout: ->
      
      deferred = $q.defer()
      
      @current_user().then (current_user) =>
        
        httpApi.delete('sessions/' + current_user.auth_token).then =>
      
          @_unset_current_user()
          
          deferred.resolve()
          
        , (error)-> deferred.reject(error)
          
      , -> deferred.reject(null)

      deferred.promise
      
    current_user: ->
      
      deferred = $q.defer()
      
      if $rootScope.current_user?
        
        deferred.resolve($rootScope.current_user)
      
      else if localStorageService.get('current_user')?
        
        user = localStorageService.get('current_user') 
        
        credentials = {user_id: user.id, auth_token: user.auth_token}
                  
        httpApi.post('sessions/authenticate_by_token', user: credentials).then (response) => #valid auth_token
          
          user = response.data
          
          @_set_current_user(user)
          
          deferred.resolve(user)
          
        , (error)-> # invalid auth_token
          
          deferred.reject(error)
          
      else
          
        deferred.reject(null)
  
      deferred.promise
    
    request_anonymous_token: ->
      
      deferred = $q.defer()
      
      if localStorageService.get('is_active_user')?
        
        deferred.resolve()
      
      else
        
        anonymous_token = $rootScope.current_anonymous_token || localStorageService.get('current_anonymous_token')
        
        if anonymous_token?
          
          @_set_current_anonymous_token(anonymous_token)
          
          deferred.resolve(anonymous_token)
            
        else
          
          httpApi.post('sessions/create_anonymous').then (response) =>
            
            @_set_current_anonymous_token(response.data.auth_token)
            
            deferred.resolve(response.data.auth_token)
            
          , (error)-> # fail to request an anonymous auth_token
            
            deferred.reject(error)
          
      deferred.promise
        
    _set_current_user: (user)->
      
      $rootScope.current_user = user
      
      localStorageService.set('current_user', user)
      
      localStorageService.set('is_active_user', true)
      
      @_unset_current_anonymous_token()
    
    _unset_current_user: ->
      
      $rootScope.current_user = null
      
      localStorageService.remove('current_user')
    
    _set_current_anonymous_token: (token)->
      
      $rootScope.current_anonymous_token = token
      
      localStorageService.set('current_anonymous_token', token)
      
    _unset_current_anonymous_token: ->
      
      $rootScope.current_anonymous_token = null
      
      localStorageService.remove('current_anonymous_token')
      
  new Authentication()
  
]