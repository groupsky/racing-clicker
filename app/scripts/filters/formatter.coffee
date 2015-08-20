'use strict'

###*
 # @ngdoc filter
 # @name swarmApp.filter:formatter
 # @function
 # @description
 # # value, filtername
 # Filter in the swarmApp.
###
angular.module('swarmApp').filter 'formatter', ($filter) ->
  (val, filter, args...) ->
    $filter(filter)(val, args...)
