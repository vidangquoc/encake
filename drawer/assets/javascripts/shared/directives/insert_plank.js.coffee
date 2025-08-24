app.directive 'insertBlank',[ '$compile', '$timeout', ($compile, $timeout) ->
  
    restrict: 'A'
    
    scope:
      content: '='
      answer: '='
      
    link: (scope, element, attrs) ->          
      
      scope.$watch 'content', ->      
        
        if(scope.content?)
          
          blank = "<span class='question_blank'></span>";
          
          element.html scope.content.replace('{...}', blank)
          
          $compile(element.contents()) scope
          
      scope.$watch 'answer', (answer) ->
        
        if answer? && answer != ''
          
          element.contents('.question_blank').addClass('answer_in_blank').removeClass('question_blank').html(" " + answer + " ");
          
]