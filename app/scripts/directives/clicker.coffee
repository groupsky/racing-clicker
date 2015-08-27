'use strict'

###*
 # @ngdoc directive
 # @name racingApp.directive:clicker
 # @description
 # # clicker
###
angular.module('racingApp').directive 'clicker', ($rootScope, $timeout, game) ->
  templateUrl: 'views/clicker.html'
  restrict: 'E'
  scope:
    game: '=?'
  controllerAs: 'clickerCtrl'
  controller: ($log, $scope, commands) ->
    savePromise = false
    game_ = $scope.game ? game

    $scope.game = game_
    $scope.units = game_.units()
    $scope.race = $scope.units.race
    $scope.races = $scope.units.races
    $scope.driving = $scope.units.driving
    $scope.fame = game.unit('fame')
    $scope.filterVisible = (upgrade) -> upgrade.isVisible()

    $scope.doClick = ($event) =>
      $log.debug 'click!'
      for name, val of $scope.driving.totalProduction()
        $scope.fame._addCount val
      $rootScope.$emit 'race',
        unit: $scope.fame
        unitname: $scope.fame.name
        num: val
        twinnum: val
        costs: {}
      $timeout.cancel savePromise if savePromise
      savePromise = $timeout ->
        game.save
        $rootScope.$emit "command",
          name: 'buyUnit'
          unit: $scope.fame
          unitname: $scope.fame.name
          now: game_.now
          elapsed: game_.elapsedStartMillis()
          attempt: val
          num: val
          twinnum: val
          costs: {}
          skipEffect: true
      , 1500

