app.factory 'serverLogger', ['$injector', ($injector) ->
  
  httpApi         = $injector.get('httpApi')
  deviceDetector  = $injector.get('deviceDetector')
  $location       = $injector.get('$location')
  
  class ServerLogger
  
    last_content: ''
  
    log: (content) ->
      
      device_info = "URL: " + $location.url()
      device_info += " | Device: " + deviceDetector.device
      device_info += " | OS: " + deviceDetector.os
      device_info += " | OS Version: " + deviceDetector.os_version
      device_info += " | Browser: " + deviceDetector.browser
      device_info += " | Browser Version: " + deviceDetector.browser_version
      
      if content != @last_content
        
        @last_content = content
        
        httpApi.post("app_logs", {content: content, type: 'Javascript', device: device_info}, {ignore_response_error_interceptor: true, ignoreLoadingBar: true})
      
      console?.log(content)
     
    log_error: (message) ->  
      
      @log(message)
      
  new ServerLogger()
  
]