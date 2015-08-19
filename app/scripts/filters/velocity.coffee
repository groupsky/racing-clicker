'use strict'

###*
 # @ngdoc filter
 # @name swarmApp.filter:estimate
 # @function
 # @description
 # # upgrade
 # Filter in the swarmApp.
###
angular.module('swarmApp').filter 'velocity', (options) ->
  (unit) ->
    unit.velocity().times(options.getVelocityUnit({unit: unit}).mult)
