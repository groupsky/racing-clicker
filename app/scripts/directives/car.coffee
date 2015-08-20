'use strict'

###*
# @ngdoc directive
# @name swarmApp.directive:car
# @description
# # car
###
angular.module('swarmApp').directive 'car', (options, game, commands) ->
  templateUrl: 'views/car.html'
  scope:
    unit: '='
  restrict: 'E'
  link: (scope) ->
    scope.velocityUnit = options.getVelocityUnit {prod:scope.unit}
    scope.game = game
    scope.filterVisible = (upgrade) -> upgrade.isVisible()
    scope.buy = (args) ->
      args.upgrade = args.resource if args.resource
      delete args.resource if args.resource
      commands.buyUpgrade args
