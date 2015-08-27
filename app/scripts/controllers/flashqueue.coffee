'use strict'

###*
 # @ngdoc function
 # @name racingApp.controller:FlashqueueCtrl
 # @description
 # # FlashqueueCtrl
 # Controller of the racingApp
###
angular.module('racingApp').controller 'FlashQueueCtrl', ($scope, flashqueue) ->
  $scope.achieveQueue = flashqueue
