app.directive 'showLevel', [ ->
  
    restrict: 'EA'
    templateUrl: 'templates/directives/show_level.html'
    replace: true
    scope:
      data: '='
      learning_progress: '=learningProgress'
    
    link: (scope, element, attrs) ->
      
      scope.$watch 'data', (-> update_level()), true
      
      update_level = ->
        
        if scope.data?
          
          previous_level = scope.data.around_levels[0]
          current_level = scope.data.around_levels[1]
          next_level = scope.data.around_levels[2]
          current_score = scope.data.current_score
          
          scope.current_level = current_level
        
          scope.next_level = next_level
          
          scope.progress_percent = calculate_current_level_progress(previous_level, current_level, current_score)
        
      calculate_current_level_progress =(previous_level, current_level, current_score) ->
    
        progress_percent = 0
        
        if(!previous_level?) #current level is the lowest level
          progress_percent = (current_score/current_level.highest_score)*100
        
        else
          current_level_score = current_level.highest_score - previous_level.highest_score
          score_gained_in_current_level = current_score - previous_level.highest_score
          progress_percent = (score_gained_in_current_level/current_level_score)*100
          
        #making the progress look faster
        if progress_percent < 50
          progress_percent = progress_percent + progress_percent/2
        else
          progress_percent = progress_percent + (100 - progress_percent)/2
                    
        progress_percent = 99 if progress_percent > 100 #current score exceeds the highest score of the highest level
            
        progress_percent
]