'use strict'

###*
 # @ngdoc filter
 # @name swarmApp.filter:estimate
 # @function
 # @description
 # # upgrade
 # Filter in the swarmApp.
###
angular.module('swarmApp').filter 'count', () ->
  (array) ->
    array.length if angular.isArray(array)
