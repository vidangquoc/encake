app.config ['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->  
  
  wait_cordova = [ '$injector', ($injector) ->
    if $injector.has('$ionicPlatform') #only for mobile apps
      deferred = $injector.get('$q').defer()
      $injector.get('$ionicPlatform').ready -> deferred.resolve();
      deferred.promise;
  ]
  
  $stateProvider
  .state('logged',
    abstract: true
    templateUrl: 'templates/layouts/logged.html'
    controller: 'LoggedLayoutCtrl'
    resolve:{
      cordova: wait_cordova
      authenticate: ['gateKeeper', (gateKeeper) ->
        gateKeeper.check()
      ]
    }
  ).state('logged.review'
    url: '/review?lesson_id&skills&reload'  
    views: 'logged_content':
        templateUrl: 'templates/review.html'
        controller: 'ReviewCtrl'
  ).state('logged.lesson'
    url: '/lessons/:lesson_id?show_back'
    views: 'logged_content':
      templateUrl: "templates/lesson.html"
      controller: 'LessonCtrl'
  ).state('logged.article'
    url: '/articles/:lesson_id?show_back'
    views: 'logged_content':
      templateUrl: "templates/lesson.html"
      controller: 'LessonCtrl'
  ).state('logged.friends'
    url: '/friends'
    views: 'logged_content':
      templateUrl: "templates/friends.html"
      controller: 'FriendsCtrl'
  ).state('logged.profile'
    url: '/profile'
    views: 'logged_content':
      templateUrl: "templates/profile.html"
      controller: 'ProfileCtrl'
  ).state('logged.version'
    url: '/version'
    views: 'logged_content':
      templateUrl: "templates/app_version.html"
      controller: 'AppVersionCtrl'
  ).state('logged.points'
    url: '/points'
    views: 'logged_content':
      templateUrl: "templates/points.html"
      controller: 'PointsCtrl'
  ).state('logged.add_point'
    url: '/add_point?content'
    views: 'logged_content':
      templateUrl: "templates/point.html"
      controller: 'PointCtrl'
  ).state('logged.edit_point'
    url: '/edit_point?point_id'
    views: 'logged_content':
      templateUrl: "templates/point.html"
      controller: 'PointCtrl'
  )
  #.state('logged.invite_friends'
  #  url: '/invite_friends',
  #  views: 'logged_content':
  #    templateUrl: "templates/invite_friends.html"
  #    controller: 'InviteFriendsCtrl'
  #).state('logged.invite_friends_directly',
  #  url: '/invite_friends_directly',
  #  views: 'logged_content':
  #    templateUrl: "templates/invite_friends_directly.html"
  #    controller: 'InviteFriendsDirectlyCtrl'
  #).state('logged.invite_friends_confirmation',
  #  url: '/invite_friends_confirmation',
  #  views: 'logged_content':
  #    templateUrl: "templates/confirm_friend_invitations.html"
  #    controller: 'ConfirmFriendInvitationsCtl'
  #)
  
  .state('anonymous',
    abstract: true
    templateUrl:'templates/layouts/anonymous.html'
    resolve:{      
      cordova: wait_cordova,
      authenticate: ['gateKeeper', (gateKeeper) ->
        gateKeeper.check_anonymous()
      ]
    }
  ).state('anonymous.login'
    url: '/login?email'
    views: 'anonymous_content':
      templateUrl: 'templates/login.html'
      controller: 'LoginCtrl'
  ).state('anonymous.register',
    url: '/register?show_back'
    views: 'anonymous_content':
      templateUrl: 'templates/register.html'
      controller: 'RegisterCtrl'
  ).state('anonymous.recover_password',
    url: '/recover_password?email&show_back'
    views: 'anonymous_content':
      templateUrl: 'templates/recover_password.html'
      controller: 'RecoverPasswordCtrl'
  ).state('anonymous.test',
    url: '/test'
    views: 'anonymous_content':
      templateUrl: 'templates/test.html'
      controller: 'TestCtrl'
  )
  #.state('anonymous.about_us',
  #  url: '/about_us'
  #  views: 'anonymous_content':
  #    templateUrl: 'templates/about_us.html'
  #)
  
  $urlRouterProvider.otherwise (injector, location) -> injector.get('$state').go('logged.review')
  
]