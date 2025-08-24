app.factory 'platform', ['$injector', ($injector) ->
  
  class PlatForm
  
    is_mobile_app: ->
      
      $injector.has('$ionicPlatform')
      
    is_web_app: ->  ! @is_mobile_app()
  
  new PlatForm()    

]      