'use strict'

###*
# @ngdoc directive
# @name swarmApp.directive:resource
# @description
# # resource
###
angular.module('swarmApp').directive 'resource', (game, util, options, version, commands) ->
  templateUrl: 'views/resource.html'
  scope:
    unit: '='
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.velocityUnit = options.getVelocityUnit({unit: scope.unit})
