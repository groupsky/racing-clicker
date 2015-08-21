'use strict'

###*
# @ngdoc directive
# @name swarmApp.directive:upgrade
# @description
# # upgrade
###
angular.module('swarmApp').directive 'upgrade', (commands) ->
  templateUrl: 'views/upgrade.html'
  scope:
    upgrade: '='
  restrict: 'E'
  link: (scope) ->
    scope.commands = commands
