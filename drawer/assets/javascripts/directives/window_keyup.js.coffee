app.directive 'windowKeyup', [ '$timeout', 'actionTracker', ($timeout, actionTracker)->
    restrict: 'EA'
    replace: true
    scope:
      up_arrow: '&upArrow'
      right_arrow: '&rightArrow'
      left_arrow: '&leftArrow'
      enter: '&'
      enabled: '='
    link: (scope, element, attrs) ->
      
      trackActions = {}
      
      if attrs.trackActions?
        
        trackActions = JSON.parse(attrs.trackActions)
      
      last_fired = null
      
      last_key_code = null
      
      $timeout ->
      
        $(window).off('keyup.enetwork').on 'keyup.enetwork', (event) ->
          
          now = time_in_milliseconds()
          
          if ( !last_fired? || (event.which != last_key_code) || (now - last_fired > 500) ) && scope.enabled
            
            fired = false
            tracked_action = null
          
            if event.which == 38 && attrs.upArrow
              
              scope.$apply(scope.up_arrow)
              
              tracked_action = trackActions.up_arrow if(trackActions.up_arrow?)
              
              fired = true
            
            if event.which == 39 && attrs.rightArrow?
              
              scope.$apply(scope.right_arrow)
              
              tracked_action = trackActions.right_arrow if(trackActions.right_arrow?)
              
              fired = true
            
            if event.which == 37 && attrs.leftArrow?
              
              scope.$apply(scope.left_arrow)
              
              tracked_action = trackActions.left_arrow if(trackActions.left_arrow?)
              
              fired = true
              
            if event.which == 13 && attrs.enter?
              
              scope.$apply(scope.enter)
              
              tracked_action = trackActions.enter if(trackActions.enter?)
              
              fired = true
              
            if fired
              
              if tracked_action?
                
                actionTracker.track({action: tracked_action, action_data: attrs.actionData})
              
              last_fired = time_in_milliseconds()
              
              last_key_code = event.which
      , 500    
        
      scope.$on "$destroy", -> $(window).off('keyup.enetwork')
      
      time_in_milliseconds = ->  (new Date()).getTime()

]