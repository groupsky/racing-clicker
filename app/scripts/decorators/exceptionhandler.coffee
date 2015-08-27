'use strict'

###*
 # @ngdoc function
 # @name racingApp.decorator:Exceptionhandler
 # @description
 # # Exceptionhandler
 # Decorator of the racingApp
###
angular.module("racingApp").config ($provide) ->
  # in most places minification can figure out what's going on without
  # argnames-as-list, but not here. Fails in dist-build without them.
  $provide.decorator "$exceptionHandler", ['$delegate', '$injector', ($delegate, $injector) ->
    $rootScope = null
    (exception, cause) ->
      $delegate exception, cause
      $rootScope ?= $injector.get '$rootScope' #avoid circular dependency error
      $rootScope.$emit 'unhandledException', {exception:exception, cause:cause}
  ]
