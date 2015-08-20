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
    unit: '='
  restrict: 'E'
  link: (scope) ->
    scope.filterVisible = (upgrade) -> upgrade.isVisible()
    scope.buy = (args) ->
      args.upgrade = args.resource if args.resource
      delete args.resource if args.resource
      commands.buyUpgrade args
    formatDuration = (estimate) ->
    scope.estimateUpgradeSecs = (upgrade) ->
      estimate = upgrade.estimateSecsUntilBuyable()
      val = estimate.val.toNumber()
      if isFinite val
        secs = moment.duration(val, 'seconds')
        #add nonexact annotation for use by filter
        secs.nonexact = not (estimate.unit?.isEstimateExact?() ? true)
        return secs
      # infinite estimate, but moment doesn't like infinite durations.
      return Infinity
