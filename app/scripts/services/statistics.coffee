'use strict'

###*
 # @ngdoc service
 # @name racingApp.statistics
 # @description
 # # statistics
 # Factory in the racingApp.
###
angular.module('racingApp').factory 'StatisticsListener', (util, $log, kongregate, game) -> class StatisticsListener
  constructor: (@session, @scope) ->
    @_init()

  _init: ->
    stats = @session.state.statistics ?= {}
    stats.byUnit ?= {}
    stats.byUpgrade ?= {}
    stats.clicks ?= 0
    stats.chartTimes ?= []
    stats.chartData ?= []

  push: (cmd) ->
    cmd.clicks ?= 1
    stats = @session.state.statistics
    stats.clicks += cmd.clicks
    if cmd.unitname?
      ustats = stats.byUnit[cmd.unitname]
      if not ustats?
        ustats = stats.byUnit[cmd.unitname] = {clicks:0,num:0,twinnum:0,elapsedFirst:cmd.elapsed}
        @scope.$emit 'buyFirst', cmd
      ustats.clicks += cmd.clicks
      ustats.cps = Math.max(ustats.cps || 0, cmd.cps) if cmd.cps?
      try
        ustats.num = new Decimal(ustats.num).plus(cmd.num)
        ustats.twinnum = new Decimal(ustats.twinnum).plus(cmd.twinnum)
      catch e
        $log.warn 'statistics corrupt for unit, resetting', cmd.unitname, ustats, e
        ustats.num = new Decimal cmd.num
        ustats.twinnum = new Decimal cmd.twinnum
    if cmd.upgradename?
      ustats = stats.byUpgrade[cmd.upgradename]
      if not ustats?
        ustats = stats.byUpgrade[cmd.upgradename] = {clicks:0,num:0,elapsedFirst:cmd.elapsed}
        @scope.$emit 'buyFirst', cmd
      ustats.clicks += cmd.clicks
      try
        ustats.num = new Decimal(ustats.num).plus(cmd.num)
      catch e
        $log.warn 'statistics corrupt for upgrade, resetting', cmd.upgradename, ustats, e
        ustats.num = new Decimal cmd.num
    @session.save() #TODO session is saved twice for every command, kind of lame
    delete cmd.now
    delete cmd.unit
    delete cmd.upgrade

  collectChartData: ->
    stats = @session.state.statistics
    seconds = game.elapsedSeconds()
    [..., lastTime] = stats.chartTimes
    lastTime ?= 0
    reportInterval = 0
    if seconds <= 10 #First 10 seconds
      reportInterval = 1
    else if seconds <= 1 * 60 #1 minute
      reportInterval = 10
    else if seconds <= 10 * 60 #10 minutes
      reportInterval = 60
    else if seconds <= 1 * 3600 #1 hour
      reportInterval = 5 * 60
    else if seconds <= 2 * 3600 #2hours
      reportInterval = 10 * 60
    else if seconds <= 12 * 360 #12 hours
      reportInterval = 30 * 60
    else
      reportInterval = 3600
    if seconds - lastTime >= reportInterval
      stats.chartTimes.push seconds
      stats.chartData.push
        research: game.unit('technology').velocity()
        money: game.unit('money').velocity()
        fame: game.unit('fake_fame').velocity()


  listen: (scope) ->
    scope.$on 'tick', =>
      this.collectChartData()
    scope.$on 'reset', =>
      @_init()
    scope.$on 'command', (event, cmd) =>
      $log.debug 'statistics', event, cmd
      @push cmd
      kongregate.reportStats()

angular.module('racingApp').factory 'statistics', (session, StatisticsListener, $rootScope) ->
  stats = new StatisticsListener session, $rootScope
  stats.listen $rootScope
  return stats
