app.directive 'pointIllustratingImagesShower', ['pointIllustratingImagesShowerHelper', (pointIllustratingImagesShowerHelper) ->
  
  templateUrl: 'templates/directives/point_illustrating_images_shower.html'
  restrict: 'AE'
  replace: true
  scope:
    point: '='
    
  link: (scope, element, attrs) ->
    
    pointIllustratingImagesShowerHelper.init(scope)
]