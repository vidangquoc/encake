app.factory 'urlHelper', [ 'Constants', (Constants)->
  
  class UrlHelper
  
    absolute_url: (path) ->
      
      Constants.asset_host + @remove_slashes_at_the_beginning(path)
      
    load_image: (path, on_load) ->
      
      img = new Image()
          
      img.src = @absolute_url(path)
    
      img.onload = ->
        
        on_load() if on_load?
        
        img = null #dispose image object
    
    remove_slashes_at_the_beginning: (url)-> url.replace(/^(\s)*(\/)*/, '')    
  
  new UrlHelper()
  
]  