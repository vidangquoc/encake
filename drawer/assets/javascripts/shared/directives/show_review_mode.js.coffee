app.directive 'showReviewMode',[ '$timeout', ($timeout) ->
  
    restrict: 'AE'
    
    templateUrl: 'templates/directives/review_mode.html'
    
    replace: true
    
    scope:
      
      mode: '=mode'
      
      on_switch: '=onModeSwitch'
      
      total_points: '=totalPoints'
      
      due_points: '=duePoints'
      
    link: (scope, element, attrs) ->
      
      scope.$watch 'mode', (mode) ->
        
        if mode?
      
          if mode == 'learning'
            
            scope.learning_classes = attrs.selectedClasses
            
            scope.reviewing_classes = attrs.unselectedClasses
            
          else
            
            scope.reviewing_classes = attrs.selectedClasses
            
            scope.learning_classes = attrs.unselectedClasses
  
      scope.switch = (mode)->
        
        scope.on_switch(mode)
    
]