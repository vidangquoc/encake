app.directive 'showRewardedLuckyStars',[ '$timeout', ($timeout) ->
  
  templateUrl: 'templates/directives/rewarded_lucky_stars.html'
  restrict: 'EA'
  replace: true
  scope:
    number_of_rewarded_lucky_stars: '=numberOfRewardedLuckyStars'
    lucky_star_image: '=luckyStarImage'
    show: '=show'
  
  link: (scope, element, attrs) ->
    
    scope.$watch 'show', (value) ->
      
      if value
        
        element.fadeIn 2000, ->
        
          $timeout ->
            element.fadeOut(2000)
          , 1000
        
]