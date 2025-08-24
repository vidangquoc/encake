app.factory 'exampleAlternativeParser', [->
  
  class ExampleAlternativeParser
  
    parse: (example_alternative) ->
      
      paterns = []
      
      while match = example_alternative.match(/\{[^{}]+\}/)
        
        paterns[paterns.length] = match[0]
        
        example_alternative = example_alternative.replace(/\{[^{}]+\}/, "[" + (paterns.length - 1) + "]")  
      
      @replace_tokens([example_alternative], paterns, 0)
      
            
    replace_tokens: (initial_alternatives, paterns, at_index) ->
      
      return initial_alternatives if at_index > paterns.length - 1
      
      result_strings = []
      
      for initial_string in initial_alternatives
        
        replace = paterns[at_index].replace(/^\{/, '').replace(/\}$/, '')
        
        tokens = replace.split('|')
        
        for token in tokens
        
          token = token.replace(/^ /, '').replace(/ $/, '')
      
          result_strings.push( initial_string.replace("[" + at_index + "]", token) )
          
      @replace_tokens(result_strings, paterns, at_index + 1)
  
  new ExampleAlternativeParser
    
]