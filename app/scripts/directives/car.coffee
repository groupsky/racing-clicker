'use strict'

###*
# @ngdoc directive
# @name swarmApp.directive:car
# @description
# # car
###
angular.module('swarmApp').directive 'car', ->
  templateUrl: 'views/car.html'
  scope:
    unit: '='
  restrict: 'E'
  link: (scope) ->
    scope.filterVisible = (upgrade) -> upgrade.isVisible()
