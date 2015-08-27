'use strict'

###*
 # @ngdoc function
 # @name racingApp.controller:LoginCtrl
 # @description
 # # LoginCtrl
 # Controller of the racingApp
###
angular.module('racingApp').controller 'LoginCtrl', ($scope, loginApi) ->
  $scope.form = {}
  $scope.submit = ->
    loginApi.login 'local', $scope.form
