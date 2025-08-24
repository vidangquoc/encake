app.directive 'teaserFeedback', ["httpApi", (httpApi) ->
  
  templateUrl: 'templates/review_feedbacks/teaser.html'
  restrict: 'AE'
  replace: false
  scope:
    data: '='
    onConfirm: '&onConfirm'
    
  link: (scope, element, attrs) ->
    
    scope.update_teaser = ->
      
      httpApi.put( '/user_actions/' + scope.data.action_id + '/update_teaser', teaser_id: scope.selected_teaser_id )
    
      scope.onConfirm()
      
]      