app.directive 'clickToSearchText',[ '$compile', ($compile) ->
  
    restrict: 'A'
    
    scope:
      onSearchFinish: '&'
      clickToSearchText: '='
    
    link: (scope, element, attrs) ->
      
      scope.$watch 'clickToSearchText' , (text) ->
        
        return if !text?
        
        splits = text.split(/\s+/)
        
        html = ''
        
        for split in splits
          
          html += " <a x-click-to-search x-on-search-finish='search_finish_handler(points)' class='click-to-search' x-no-track-action >" + split + "</a>"
          
        element.html html
        
        $compile(element.contents()) scope
        
      scope.search_finish_handler = (points) ->
        
        scope.onSearchFinish(points: points)

]