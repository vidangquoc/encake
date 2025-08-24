app.directive 'clickToSearch',[ 'httpApi', (httpApi) ->
  
    restrict: 'A'
    scope:
      onSearchFinish: '&'
    
    link: (scope, element, attrs) ->
      
      element.on 'click', ->
        
        searched_key = element.text()
         
        httpApi.get('points/search_including_variations', params: {key: searched_key}).then (response) ->
          
          scope.onSearchFinish(points: response.data)
          
]