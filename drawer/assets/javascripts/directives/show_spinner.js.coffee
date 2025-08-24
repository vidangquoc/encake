app.directive 'showSpinner', [ ->
  
  restrict: 'A'
  scope:
    visible: '=showSpinner'
    
  link: (scope, element, attrs) ->
    
    $spinner = element.clone().off().empty().prop('disabled', true).hide()
    
    $('<i>').addClass('fa fa-spinner fa-spin').appendTo($spinner)
    
    $('<span>').html(' ' + (attrs.spinnerText || '') ).appendTo($spinner)
    
    element.after($spinner)
    
    scope.$watch 'visible', (value) ->

      if value == true
        
        element.hide()
        $spinner.show()
        
      else
        
        element.show()
        $spinner.hide()
      
]      