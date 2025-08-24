app.directive 'opportunityModal', ['opportunityModalHelper', (helper) ->
  
  templateUrl: 'templates/directives/opportunity_modal.html'
  restrict: 'AE'
  replace: true
  scope:
    visible: '='
    opportunity: '='
    after_show: '&afterShow'
    before_hide: '&beforeHide'
    
  link: (scope, element, attrs) ->
    
    helper.init(scope, hide_modal: ( -> element.modal('hide') ) , show_modal: ( -> element.modal 'show' ) )
  
    element.on 'shown.bs.modal', -> helper.on_modal_show(attrs)
      
    element.on 'hidden.bs.modal', -> helper.on_modal_hide(attrs)
      
]