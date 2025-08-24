app.directive 'resetValidationMessageOnChange', ->
    
  restrict: 'A'
  
  require: 'ngModel'
  
  link: (scope, elm, attrs) ->      
        
    form = elm.inheritedData('$formController')
          
    return if !form
     
    scope.$watch attrs.ngModel, ->
       
      form[attrs.name].$error[attrs.name] = null
      
      form[attrs.name].$invalid = false
