app.directive 'showAddedScore',[ '$timeout', ($timeout) ->
  
  templateUrl: 'templates/directives/added_score.html'
  restrict: 'EA'
  replace: true
  scope:
    score: '='
    show: '=show'
  
  link: (scope, element, attrs) ->
    
    scope.$watch 'show', (value) ->
      
      if value
        
        element.fadeIn 2000, ->
        
          $timeout ->
            element.fadeOut(2000)
          , 1000
        
]