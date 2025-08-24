app.factory 'Uploader', ['$rootScope', 'Upload', 'Constants', ($rootScope, Upload, Constants) ->
  
  class Uploader
  
    upload: (config)->
      
      config.url = Constants.api_endpoint + config.url
      
      if $rootScope.current_user?
      
        config.headers = {
          'AUTH_USER_ID': $rootScope.current_user.id,
          'AUTH_TOKEN': $rootScope.current_user.auth_token
        }
      
      @_strip_null_values(config.data) 
    
      Upload.upload(config)
      
    _strip_null_values: (object)->
      for key, value of object
        if value == null
          delete object[key]
        else if typeof(value) == "object"
          @_strip_null_values(value)
        
      
  new Uploader()

]