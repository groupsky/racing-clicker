'use strict'

###*
# @ngdoc directive
# @name swarmApp.directive:car
# @description
# # car
###
angular.module('swarmApp').directive 'car', (options, game) ->
  templateUrl: 'views/car.html'
  scope:
    unit: '='
  restrict: 'E'
  link: (scope) ->
    scope.filterVisible = (upgrade) -> upgrade.isVisible()
    scope.velocityUnit = options.getVelocityUnit {prod:scope.unit}
    scope.game = game
