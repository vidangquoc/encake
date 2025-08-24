###*! 
# @license angular-flash v0.1.14
# Copyright (c) 2013 William L. Bunselmeyer. https://github.com/wmluke/angular-flash
# License: MIT
###

### global angular ###

do ->
  'use strict'
  subscriberCount = 0
  dismissSubscriberCount = 0

  Flash = (options) ->
    _options = angular.extend({
      id: null
      subscribers: {}
      dismissSubscribers: {}
      classnames:
        error: []
        warn: []
        info: []
        success: []
    }, options)
    _self = this
    _success = undefined
    _success_next = undefined
    _info = undefined
    _info_next = undefined
    _warn = undefined
    _warn_next = undefined
    _error = undefined
    _error_next = undefined
    _type = undefined
    _next = false

    _notify = (type, message) ->
      return if !message? || message == ''
      angular.forEach _options.subscribers, (subscriber) ->
        matchesType = !subscriber.type or subscriber.type == type
        matchesId = !_options.id and !subscriber.id or subscriber.id == _options.id
        if matchesType and matchesId
          subscriber.cb message, type
      return

    @clean = ->
      _success = null
      _info = null
      _warn = null
      _error = null
      _type = null

    @apply_nexts = ->
      if _success_next != null
        _self.success = _success_next
        _success_next = null
      if _info_next != null
        _self.info = _info_next
        _info_next = null
      if _warn_next != null
        _self.warn = _warn_next
        _warn_next = null
      if _error_next != null
        _self.error = _error_next
        _error_next = null
      return

    @subscribe_dismiss = (subscriber, id) ->
      dismissSubscriberCount += 1
      _options.dismissSubscribers[dismissSubscriberCount] =
        cb: subscriber
        id: id
      dismissSubscriberCount

    @unsubscribe_dismiss = (handle) ->
      delete _options.dismissSubscribers[handle]
      return

    @subscribe = (subscriber, type, id) ->
      subscriberCount += 1
      _options.subscribers[subscriberCount] =
        cb: subscriber
        type: type
        id: id
      subscriberCount

    @unsubscribe = (handle) ->
      delete _options.subscribers[handle]
      return

    @to = (id) ->
      `var options`
      options = angular.copy(_options)
      options.id = id
      new Flash(options)

    @dismiss = (id) ->
      angular.forEach _options.dismissSubscribers, (subscriber) ->
        matchesId = !_options.id and !subscriber.id or subscriber.id == _options.id or id == ':all'
        if matchesId
          subscriber.cb()
        return
      return

    Object.defineProperty this, 'next', get: ->
      _next = true
      _self
    Object.defineProperty this, 'success',
      get: ->
        _success
      set: (message) ->
        if _next
          _success_next = message
          _next = false
        else
          _success = message
          _type = 'success'
          _notify _type, message
        return
    Object.defineProperty this, 'info',
      get: ->
        _info
      set: (message) ->
        if _next
          _info_next = message
          _next = false
        else
          _info = message
          _type = 'info'
          _notify _type, message
        return
    Object.defineProperty this, 'warn',
      get: ->
        _warn
      set: (message) ->
        if _next
          _warn_next = message
          _next = false
        else
          _warn = message
          _type = 'warn'
          _notify _type, message
        return
    Object.defineProperty this, 'error',
      get: ->
        _error
      set: (message) ->
        if _next
          _error_next = message
          _next = false
        else
          _error = message
          _type = 'error'
          _notify _type, message
        return
    Object.defineProperty this, 'type', get: ->
      _type
    Object.defineProperty this, 'message', get: ->
      if _type then _self[_type] else null
    Object.defineProperty this, 'classnames', get: ->
      _options.classnames
    Object.defineProperty this, 'id', get: ->
      _options.id
    return

  angular.module('angular-flash.service', []).provider('flash', ->
    _self = this
    @errorClassnames = [ 'alert-danger' ]
    @warnClassnames = [ 'alert-warn' ]
    @infoClassnames = [ 'alert-info' ]
    @successClassnames = [ 'alert-success' ]

    @$get = ->
      new Flash(classnames:
        error: _self.errorClassnames
        warn: _self.warnClassnames
        info: _self.infoClassnames
        success: _self.successClassnames)

    return
  ).run [
    '$rootScope'
    'flash'
    ($rootScope, flash) ->
      $rootScope.$on '$stateChangeSuccess', ->
        flash.error = ''
        flash.success = ''
        flash.info = ''
        flash.dismiss(':all')
        flash.apply_nexts()
        return
      return
  ]
  return

### global angular ###

do ->

  isBlank = (str) ->
    if str == null or str == undefined
      str = ''
    /^\s*$/.test str

  flashAlertDirective = (flash, $timeout) ->
    {
      scope: true
      link: ($scope, element, attr) ->
        $scope.alert_shown = false
        timeoutHandle = undefined
        subscribeHandle = undefined
        dismissSubscribeHandle = undefined

        removeAlertClasses = ->
          classnames = [].concat(flash.classnames.error, flash.classnames.warn, flash.classnames.info, flash.classnames.success)
          angular.forEach classnames, (clazz) ->
            element.removeClass clazz

        show = (message, type) ->
          if timeoutHandle
            $timeout.cancel timeoutHandle
          $scope.flash.type = type
          $scope.flash.message = message
          removeAlertClasses()
          angular.forEach flash.classnames[type], (clazz) ->
            element.addClass clazz
          if !isBlank(attr.activeClass)
            element.addClass attr.activeClass
          delay = Number(attr.duration or 5000)
          if delay > 0
            timeoutHandle = $timeout($scope.hide, delay)
          $scope.alert_shown = true

        $scope.flash = {}

        $scope.hide = ->
          removeAlertClasses()
          $scope.alert_shown = false
          
        $scope.$watch('alert_shown', (value) ->
          if !isBlank(attr.activeClass)
            element.toggleClass(attr.activeClass, value)          
        )

        $scope.$on '$destroy', ->
          flash.clean()
          flash.unsubscribe subscribeHandle
          flash.unsubscribe_dismiss dismissSubscribeHandle
          
        subscribeHandle = flash.subscribe(show, attr.flashAlert, attr.id)
        dismissSubscribeHandle = flash.subscribe_dismiss($scope.hide, attr.id)

        ###*
        # Fixes timing issues: display the last flash message sent before this directive subscribed.
        ###

        if attr.flashAlert and flash[attr.flashAlert]
          show flash[attr.flashAlert], attr.flashAlert
        if !attr.flashAlert and flash.message
          show flash.message, flash.type

    }

  'use strict'
  angular.module('angular-flash.flash-alert-directive', [ 'angular-flash.service' ]).directive 'flashAlert', [
    'flash'
    '$timeout'
    flashAlertDirective
  ]
