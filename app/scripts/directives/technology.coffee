'use strict'

###*
# @ngdoc directive
# @name swarmApp.directive:technology
# @description
# # technology
###
angular.module('swarmApp').directive 'technology', ->
  templateUrl: 'views/technology.html'
  scope:
    unit: "="
  restrict: 'E'
