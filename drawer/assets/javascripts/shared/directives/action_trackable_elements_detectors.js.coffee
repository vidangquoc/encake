for directive in ['button', 'btn', 'i', 'a']
  
  app.directive directive,[ '$state', '$timeout', ($state, $timeout) ->
    
    restrict: 'EC'
  
    link: (scope, element, attrs) ->
      
      $timeout -> 
      
        if !attrs.trackAction? && !attrs.noTrackAction? && !element.hasClass('disable-pointer-events')
          
          tracked_parent = element.closest('[x-track-action], [x-no-track-action], .popup-buttons')
          
          if tracked_parent.length == 0
            
            console.log "Potential untracked action: (" + $state.current.name + ") " + jQuery?('<div>').append(element.clone()).html()
            
            element.css({border: 'solid red 5px', lineHeight: '2em'}).show()
            
       ,2000
  ]