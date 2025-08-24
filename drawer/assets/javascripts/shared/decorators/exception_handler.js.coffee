app.config [ '$provide', ($provide) ->
  
  $provide.decorator '$exceptionHandler', [ '$delegate', '$injector', ($delegate, $injector) ->
    
    (exception, cause) ->
      
      serverLogger = serverLogger || $injector.get('serverLogger')
      
      message = exception.message
      
      message += ' (CAUSED BY: "' + cause + '")' if cause?
      
      serverLogger.log_error(message)
      
      $delegate exception, cause
      
  ]
  
] 