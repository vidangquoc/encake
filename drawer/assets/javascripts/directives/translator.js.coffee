app.directive 'translator', ->
  
    restrict: 'C'
    
    replace: true
    
    link: (scope, element, attrs) ->
      
      $tooltip_trigger = $('<div>').addClass('tooltip-trigger').attr('title', attrs.title).html('vi').appendTo(element)
      
      $tooltip_trigger.powerTip placement: 'nw-alt', fadeInTime: 0, offset: 8, smartPlacement: true
      
      $('<div>').addClass('mark').html('vi').attr('title', attrs.title).appendTo(element)