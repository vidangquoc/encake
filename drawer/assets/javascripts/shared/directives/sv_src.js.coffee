app.directive 'svSrc', [ 'urlHelper', '$timeout', (urlHelper, $timeout) ->
  
    restrict: 'A'
    scope:
      svSrc: '@'
    
    link: (scope, element, attrs) ->
      
      loadImage = ->
        
        if scope.svSrc? && scope.svSrc != ""
          
          hideOnLoading = if attrs.hideOnLoading && attrs.hideOnLoading == 'false' then false else true
          
          element.hide() if hideOnLoading
          
          urlHelper.load_image scope.svSrc,
          
            -> element.attr('src',  urlHelper.absolute_url(scope.svSrc) ).show()
          
      scope.$watch 'svSrc', ->
        
        loadImage()
        
]