app.directive 'serverValidationMessageCollector', ->
  
  link: (scope, element, attr) ->

    form = element.inheritedData('$formController')
    
    return if !form
  
    scope.$watch attr.serverValidationMessageCollector, (errors) ->
      
      if (!errors) 
        
        return;
        
      for key, messages of errors
        
        if(form[key]?)
          
          form[key].$error[key] = messages[0]
          
          form[key].$invalid = true
      
        