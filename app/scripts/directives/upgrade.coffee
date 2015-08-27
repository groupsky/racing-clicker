'use strict'

###*
# @ngdoc directive
# @name racingApp.directive:upgrade
# @description
# # upgrade
###
angular.module('racingApp').directive 'upgrade', (commands) ->
  templateUrl: 'views/upgrade.html'
  scope:
    upgrade: '='
  restrict: 'E'
  link: (scope) ->
    scope.commands = commands
    scope.totalCostVal = (cost) ->
      # stringifying scope.num is important to avoid decimal.js precision errors
      cost.val.times(1)
    scope.isCostMet = (cost) ->
      cost.unit.count().greaterThanOrEqualTo(scope.totalCostVal(cost))
