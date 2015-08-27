'use strict'

###*
 # @ngdoc filter
 # @name racingApp.filter:estimate
 # @function
 # @description
 # # upgrade
 # Filter in the racingApp.
###
angular.module('racingApp').filter 'count', () ->
  (array) ->
    array.length if angular.isArray(array)
