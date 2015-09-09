'use strict'

###*
# @ngdoc directive
# @name racingApp.directive:upgrade
# @description
# # upgrade
###
angular.module('racingApp').directive 'velocityChart', (commands) ->
  templateUrl: 'views/velocity-chart.html'
  scope:
    unit: '='
  restrict: 'E'
  controller: 'ChartCtrl'
