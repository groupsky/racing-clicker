'use strict'

###*
 # @ngdoc filter
 # @name racingApp.filter:estimate
 # @function
 # @description
 # # upgrade
 # Filter in the racingApp.
###
angular.module('racingApp').filter 'velocity', (options) ->
  (unit) ->
    unit.velocity().times(options.getVelocityUnit({unit: unit}).mult)
