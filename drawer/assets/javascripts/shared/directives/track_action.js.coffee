app.directive 'trackAction',[ 'actionTracker', '$timeout', (actionTracker, $timeout) ->
  
    restrict: 'A'
    
    link: (scope, element, attrs) ->
      
      element.on "click", ->
        
        $timeout ->
        
          actionTracker.track({action: attrs.trackAction, action_data: attrs.actionData})
          
        , 100
        
]