### ng-infinite-scroll - v1.0.0 - 2013-02-23 ###
mod = angular.module('infinite-scroll', [])
mod.directive 'infiniteScroll', ['$rootScope','$window','$timeout', ($rootScope, $window, $timeout) ->
    { link: (scope, elem, attrs) ->
      $window = angular.element($window)
      scrollDistance = 0
      if attrs.infiniteScrollDistance != null
        scope.$watch attrs.infiniteScrollDistance, (value) ->
          scrollDistance = parseInt(value, 10)
      scrollEnabled = true
      checkWhenEnabled = false
      if attrs.infiniteScrollDisabled != null
        scope.$watch attrs.infiniteScrollDisabled, (value) ->
          scrollEnabled = !value
          if scrollEnabled and checkWhenEnabled
            checkWhenEnabled = false
            handler()

      handler = ->        
        windowBottom = $window.height() + $window.scrollTop()
        elementBottom = elem.offset().top + elem.height()
        remaining = elementBottom - windowBottom
        shouldScroll = remaining <= $window.height() * scrollDistance
        if shouldScroll and scrollEnabled
          if $rootScope.$$phase
            scope.$eval(attrs.infiniteScroll)
          else
            scope.$apply(attrs.infiniteScroll)
        else if shouldScroll
          checkWhenEnabled = true

      $window.on 'scroll', handler
      scope.$on '$destroy', ->
        $window.off 'scroll', handler
      $timeout (->
        if attrs.infiniteScrollImmediateCheck
          if scope.$eval(attrs.infiniteScrollImmediateCheck)
            handler()
        else
          handler()
      ), 0
 }
]
