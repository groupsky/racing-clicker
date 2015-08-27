'use strict'

###*
 # @ngdoc filter
 # @name racingApp.filter:estimate
 # @function
 # @description
 # # upgrade
 # Filter in the racingApp.
###
angular.module('racingApp').filter 'estimate', ->
  (upgrade) ->
    estimate = upgrade.estimateSecsUntilBuyable()
    val = estimate.val.toNumber()
    if isFinite val
      secs = moment.duration(val, 'seconds')
      #add nonexact annotation for use by filter
      secs.nonexact = not (estimate.unit?.isEstimateExact?() ? true)
      return secs
    # infinite estimate, but moment doesn't like infinite durations.
    return Infinity
