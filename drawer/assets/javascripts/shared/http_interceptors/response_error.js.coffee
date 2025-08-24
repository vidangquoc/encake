app.service('HttpResponseErrorInterceptor',['$injector', ($injector) ->
  
  $q = $injector.get('$q')
  
  responseError: (error) ->
    
    if error.status != 401 && error.config? && ! error.config?.ignore_response_error_interceptor #Ignore Unauthorized error code
      
      serverLogger = $injector.get('serverLogger')
      
      message = "Http Error: "
      message += " | Status Code: " + error.status
      message += " | status Text : " + error.statusText
      
      serverLogger.log message
      
    $q.reject error
      
]).config ['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push 'HttpResponseErrorInterceptor'
]
