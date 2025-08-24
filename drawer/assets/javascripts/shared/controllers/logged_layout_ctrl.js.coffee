app.controller('LoggedLayoutCtrl', ['$scope', '$injector', ($scope, $injector) ->
  
  platform    = $injector.get('platform')
  $state      = $injector.get('$state')
  $rootScope  = $injector.get('$rootScope')
  $window     = $injector.get('$window')
  serverLogger     = $injector.get('serverLogger')
  authentication   = $injector.get('authentication')
    
  $scope.logout = ->
    
    authentication.logout().then ->
      
      $window.location.reload(true) 
  
  $scope.go_back = -> $window.history.back();
  
  if platform.is_mobile_app()
    
    #Initialize push notification
    $injector.get('pushNotificationHandler').init()
    
    #Update app code with new release from Ionic Deploy
    $ionicPopup = $injector.get('$ionicPopup')  
    deploy = new Ionic.Deploy()
    
    if $rootScope.current_user.user_type == 'tester'
      deploy.setChannel("staging")
    else if $rootScope.current_user.user_type == 'new_change_eager'
      deploy.setChannel("eager") 
  
    $scope.doUpdate = ->
      $scope.showUpdatingProgress()
      deploy.update().then ((res) ->
      ), ((err) ->
        serverLogger.log('Ionic Deploy: Update error!')
      ), (prog) ->
        $scope.setUpdatingProgressValue(prog);
  
    $scope.checkForUpdates = ->
      deploy.check().then ((hasUpdate) ->
        if hasUpdate
          $scope.showUpdatePopup() 
      ), (err) -> serverLogger.log 'Ionic Deploy: Unable to check for updates: ' + err
    
    $scope.showUpdatePopup = ->
      
      updatePopup = $ionicPopup.show(
        title: 'Ứng dụng có phiên bản mới.'
        subTitle: 'Xin vui lòng cập nhật!'
        scope: $scope
        buttons: [
          {
            text: 'Cập Nhật'
            type: 'button-positive'
            onTap: (e) ->
              updatePopup.close()
              $scope.doUpdate()
          }
        ])
    
    $scope.showUpdatingProgress = ->
      
      $scope.progressval = 0
      
      $injector.get('$ionicLoading').show({
        scope: $scope
        template: '<progress max="100" value="{{ progressval }}" style="width: 150px"> </progress>'
      })
    
    $scope.setUpdatingProgressValue = (value)->
      if(value >= 100)
        $injector.get('$ionicLoading').hide()
      else
        $scope.progressval = value
        
    $scope.checkForUpdates();

]);