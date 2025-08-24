app.factory 'actionTracker', ['$injector', ($injector) ->
  
  httpApi     = $injector.get('httpApi')
  date  = $injector.get('date')
  $state = $injector.get('$state')
  deviceDetector  = $injector.get('deviceDetector')
  
  class ActionTracker
  
    track: (action)->
      
      device_info = "Device: " + deviceDetector.device
      device_info += " | OS: " + deviceDetector.os
      device_info += " | OS Version: " + deviceDetector.os_version
      device_info += " | Browser: " + deviceDetector.browser
      device_info += " | Browser Version: " + deviceDetector.browser_version
      
      action.action_time =  date.current_timestamp()
      action.view = $state.current.name
      action.device = device_info
      
      httpApi.post("user_ui_actions", {user_ui_action: action}, ignoreLoadingBar: true)
  
  new ActionTracker()
  
]