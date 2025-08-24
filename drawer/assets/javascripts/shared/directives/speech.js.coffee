app.directive 'speech', ['dmp', '$rootScope', '$timeout', (dmp, $rootScope, $timeout)->
  
  restrict: 'A', # only activate on element attribute
  
  scope:
    speech_model: '=speechModel'
    on_start: '&onStart'
    
  link: (scope, element, attrs) ->
    
    if annyang?
      
      start_listening = ->
        scope.$apply(scope.on_start) if scope.on_start?
        scope.listening = true
        annyang.start(continuous: true) if ! annyang.isListening()
      
      speech_recognition_stopped = ->
        scope.listening = false
        element.removeClass(attrs.speechActiveClasses).addClass(attrs.speechInactiveClasses)
      
      broadcast_speech_recognition_stopped = -> $rootScope.$broadcast 'speech_recognition_stopped'
      
      broadcast_speech_recognition_started = -> $rootScope.$broadcast 'speech_recognition_started'
      
      timeout_broadcast_speech_recognition_stopped = -> $timeout( broadcast_speech_recognition_stopped, 1000)
                  
      annyang.addCallback 'errorNetwork', timeout_broadcast_speech_recognition_stopped
        
      annyang.addCallback 'errorPermissionBlocked', timeout_broadcast_speech_recognition_stopped
        
      annyang.addCallback 'errorPermissionDenied', timeout_broadcast_speech_recognition_stopped
  
      annyang.setLanguage('en-US')
      annyang.addCallback 'result', (phrases) ->
        if scope.listening
          scope.$apply ->
            scope.speech_model = phrases[0]
            annyang.abort()
            
          broadcast_speech_recognition_stopped()
      
      speech_recognition_stopped()
      
      trigger = if attrs.speechTriggerId? then angular.element('#' + attrs.speechTriggerId) else element
      
      trigger.on 'click', ->
        if !scope.listening
          start_listening()
          broadcast_speech_recognition_started()
        else
          annyang.abort()
          broadcast_speech_recognition_stopped()
          
      scope.$on '$destroy', ->
        annyang.abort()
        annyang.removeCallback()
        
      scope.$on 'speech_recognition_stopped', -> speech_recognition_stopped()
      
      scope.$on 'speech_recognition_started', -> element.removeClass(attrs.speechInactiveClasses).addClass(attrs.speechActiveClasses)
      
    else
      
      element.addClass(attrs.speechUnavailableClasses)
]  