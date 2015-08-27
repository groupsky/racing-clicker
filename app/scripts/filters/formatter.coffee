'use strict'

###*
 # @ngdoc filter
 # @name racingApp.filter:formatter
 # @function
 # @description
 # # value, filtername
 # Filter in the racingApp.
###
angular.module('racingApp').filter 'formatter', ($filter) ->
  (val, filter, args...) ->
    $filter(filter)(val, args...)
