app.directive 'pointSearchingResultModal', ->
  
  templateUrl: 'templates/directives/point_searching_result_modal.html'
  restrict: 'AE'
  replace: true
  scope:
    visible: '='
    points: '='
    after_show: '&afterShow'
    before_hide: '&beforeHide'
    
  link: (scope, element, attrs) ->
    
    scope.$watch 'visible', (value) ->
      
      if value == true
        
        element.modal 'show'
        
      else
        
        element.modal 'hide'
        
    element.on 'shown.bs.modal', ->
      
      scope.$apply -> scope.visible = true
      
      scope.$apply(scope.after_show) if attrs.afterShow?
      
    element.on 'hidden.bs.modal', ->
      
      scope.$apply -> scope.visible = false
      
      scope.$apply(scope.before_hide) if attrs.beforeHide?
    
    scope.close_modal = ->
      
      scope.visible = false