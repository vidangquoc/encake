app.directive 'autoCollapse', [ '$timeout', ($timeout)->
  
  restrict: 'A', # only activate on element attribute
    
  link: (scope, element) ->
    
    $('li', element).on 'click', -> element.collapse('hide')
    
]  