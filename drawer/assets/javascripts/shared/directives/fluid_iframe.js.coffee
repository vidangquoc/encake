app.directive 'fluidIframe',['$timeout', ($timeout) ->
  
  restrict: 'A'
  
  link: (scope, element, attrs) ->
    
    ratio = element.width()/element.height()
    
    element.css(width: '100%')
    
    event_scope = 'fluid_iframe_' + Math.round(Math.random()*10000000000)
  
    $(window).on 'resize.' + event_scope, ->
      
      element.css(height: element.width()/ratio )
    
    $timeout ->
      element.css(height: element.width()/ratio )
    , 100
    
    scope.$on '$destroy', -> $(window).off 'resize.' + event_scope
           
]