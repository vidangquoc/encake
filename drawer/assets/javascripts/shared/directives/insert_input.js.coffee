app.directive 'insertInput',[ '$compile', '$timeout', ($compile, $timeout) ->
  
    restrict: 'A'
    
    scope:
      content: '='
      linkInputTo: '='
      focusWhen: '='
      widthSpecifier: '='
    
    link: (scope, element, attrs) ->          
      
      scope.$watch 'content', ->      
        
        if(scope.content?)
          
          element.html scope.content.replace('{...}', "<input ng-model='linkInputTo' class='answer_input' x-stop-propagating-of-backward-and-forward-keys-keyup-event />")
          
          $compile(element.contents()) scope
      
      scope.$watch 'focusWhen', ->
        
        $timeout ->
        
          element.find('.answer_input').focus()
          
      scope.$watch 'widthSpecifier', ->
        
        if scope.widthSpecifier?
          
          width = Math.ceil(scope.widthSpecifier.length/2)
          
          width = (if width < 4 then 4 else width)
            
          width = (if width > 10 then 10 else width)  
          
          element.find('.answer_input').css('width', width + 'em')

]