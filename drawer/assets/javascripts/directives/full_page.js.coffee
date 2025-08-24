app.directive 'fullPage', [ '$timeout', ($timeout)->
  
    restrict: 'A', # only activate on element attribute
    
    link: (scope, element) ->
      
      resize_to_full = ->
        
        #top_navbar = parseInt( $('#top_navbar').css('padding-top'), 10 )
        top_navbar = $('#top_navbar').outerHeight()
    
        viewport_height = $(window).height()
      
        element.css( height: viewport_height - top_navbar).show()
      
      scope.$on "$stateChangeSuccess", -> 
        $timeout(resize_to_full, 200)
        $timeout(resize_to_full, 800)
        $timeout(resize_to_full, 2000)
      
      $(window).on 'resize.enetwork load.enetwork', -> resize_to_full()
        
      scope.$on "$destroy", -> $(window).off('resize.enetwork load.enetwork')
      
]