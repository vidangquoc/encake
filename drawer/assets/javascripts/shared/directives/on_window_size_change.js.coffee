app.directive 'onWindowSizeChange',[ ->
  
    restrict: 'A'
    scope:
      onWindowSizeChange: '&'
    
    link: (scope, element, attrs) ->
      
      scope.onWindowSizeChange(width: $(document).width(), height: $(document).height())
      
      $(window).on 'resize.on_window_size_change', =>
      
        scope.onWindowSizeChange(width: $(document).width(), height: $(document).height())
          
      scope.$on "$destroy", -> $(window).off('resize.on_window_size_change')
  
          
]