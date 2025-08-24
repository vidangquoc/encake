#app.service('AuthenticationHeadersInterceptor',['$injector', ($injector) ->
#  
#  $rootScope = $injector.get('$rootScope')
#  Constants = $injector.get('Constants')
#  
#  request: (config) ->
#    
#    if($rootScope.current_user?)
#      
#      config.headers = {
#        'AUTH-USER-ID': $rootScope.current_user.id,
#        'AUTH-TOKEN': $rootScope.current_user.auth_token,
#        'API-VERSION': Constants.api_version
#      }  
#     
#    return config
#      
#]).config ['$httpProvider', ($httpProvider) ->
#  $httpProvider.interceptors.push 'AuthenticationHeadersInterceptor'
#]
