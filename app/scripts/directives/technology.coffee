'use strict'

###*
# @ngdoc directive
# @name swarmApp.directive:technology
# @description
# # technology
###
angular.module('swarmApp').directive 'technology', (commands, parseNumber) ->
  templateUrl: 'views/technology.html'
  scope:
    unit: "="
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.commands = commands
    scope.form = {buyCount:''}
    _buyCount = Decimal.ONE
    scope.buyCount = ->
      parsed = parseNumber(scope.form.buyCount or '1', scope.unit) ? Decimal.ONE
      # caching required for angular
      if not parsed.equals _buyCount
        _buyCount = parsed
      return _buyCount
