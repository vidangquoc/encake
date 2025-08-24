app.directive 'teaserUpdateModal', ["httpApi", (httpApi) ->
  
  templateUrl: 'templates/directives/teaser_update_modal.html'
  restrict: 'AE'
  replace: true
  scope:
    visible: '='
    data: '='
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
    
    scope.update_teaser = ->
      
      element.modal('hide')
      
      httpApi.put( attrs.updateTeaserPath.replace( '(action_id)', scope.data.action_id), teaser_id: scope.selected_teaser_id )
      
]      