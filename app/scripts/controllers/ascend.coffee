'use strict'

###*
 # @ngdoc function
 # @name racingApp.controller:AscendCtrl
 # @description
 # # AscendCtrl
 # Controller of the racingApp
###
angular.module('racingApp').controller 'AscendCtrl', ($scope, game, commands) ->
  $scope.offers = game.ascendOffers()
