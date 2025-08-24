app.factory "httpApi", ['$http', '$rootScope', 'Upload', 'Constants', ($http, $rootScope, Upload, Constants)->
  
  httpApi = (config)->
    
    add_authentication_headers(config)
    
    config.url = api_url(config.url)
    
    $http(config)
  
  httpApi.get = (url, config) ->
    
    config = config || {}
    
    add_authentication_headers(config)
    
    $http.get(api_url(url), config)
  
  httpApi.post = (url, data, config) ->
    
    config = config || {}
    
    add_authentication_headers(config)
    
    $http.post(api_url(url), data, config)
  
  httpApi.put = (url, data, config) ->
    
    config = config || {}
    
    add_authentication_headers(config)
    
    $http.put(api_url(url), data, config)
  
  httpApi.delete = (url, config) ->
    
    config = config || {}
    
    add_authentication_headers(config)
    
    $http.delete(api_url(url), config)
    
  httpApi.upload = (config) ->
    
    config.url = api_url(config.url)
      
    add_authentication_headers(config)
    
    strip_null_values(config.data) 
    
    Upload.upload(config)
      
  strip_null_values = (object)->
    for key, value of object
      if value == null
        delete object[key]
      else if typeof(value) == "object"
        strip_null_values(value)
    
  remove_slashes_at_the_beginning = (url)-> url.replace(/^(\s)*(\/)*/, '')
    
  api_url = (url) -> Constants.api_endpoint + remove_slashes_at_the_beginning(url)
  
  add_authentication_headers = (config)->
    
    config.headers = {}
    
    config.headers['API-VERSION'] = Constants.api_version
    
    if($rootScope.current_user?)
      
      config.headers['AUTH-USER-ID'] = $rootScope.current_user.id
      config.headers['AUTH-TOKEN'] = $rootScope.current_user.auth_token 
    
    else if ($rootScope.current_anonymous_token?)
      
      config.headers['AUTH-TOKEN'] = $rootScope.current_anonymous_token
      
    
  return httpApi
    
]