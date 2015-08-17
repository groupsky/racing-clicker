'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:clicker
 # @description
 # # clicker
###
angular.module('swarmApp').directive 'clicker', (game) ->
  templateUrl: 'views/clicker.html'
  restrict: 'E'
  scope:
    game: '=?'
  controllerAs: 'clickerCtrl'
  controller: ($log, $scope, commands) ->
    game_ = $scope.game ? game

    $scope.game = game_
    $scope.units = game_.units()
    $scope.race = $scope.units.race
    $scope.races = $scope.units.races
    $scope.driving = $scope.units.driving

    $scope.doClick = ($event) =>
      $log.debug 'click!'
      count = $scope.driving.count();
      commands.buyUnit
        unit: $scope.race
        num: count
      $scope.races?._addCount 1
