'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:StatisticsCtrl
 # @description
 # # StatisticsCtrl
 # Controller of the swarmApp
###
angular.module('swarmApp').controller 'StatisticsCtrl', ($scope, session, statistics, game, options, util, $filter) ->
  $scope.listener = statistics
  $scope.session = session
  $scope.statistics = session.state.statistics
  $scope.game = game

  $scope.unitStats = (unit) ->
    ustatistics = _.clone $scope.statistics.byUnit?[unit?.name]
    if ustatistics?
      ustatistics.elapsedFirstStr = util.utcdoy ustatistics.elapsedFirst
    return ustatistics
  $scope.hasUnitStats = (unit) -> !!$scope.unitStats unit
  $scope.showStats = (unit) -> $scope.hasUnitStats(unit) or (!unit.isBuyable() and unit.isVisible())

  $scope.upgradeStats = (upgrade) ->
    ustatistics = $scope.statistics.byUpgrade[upgrade.name]
    if ustatistics?
      ustatistics.elapsedFirstStr = util.utcdoy ustatistics.elapsedFirst
    return ustatistics
  $scope.hasUpgradeStats = (upgrade) -> !!$scope.upgradeStats upgrade

  bignumFilter = $filter('bignum')
  durationFilter = $filter('duration')
  $scope.chartData = () ->
    @chart ?= {}
    @chart.type = "LineChart"
    @chart.data = {
      "cols": [
        {id: "time", label: "time", type: "string"}
        {id: "research", label: "research point", type: "number"}
        {id: "money", label: "money", type: "number"}
        {id: "fame", label: "fame", type: "number"}
      ]
    }
    @chart.data.rows = []
    for time, timeKey in $scope.statistics.chartTimes
      row = {c:[{v: time, f: durationFilter(time * 1000)}]}
      for stat, value of $scope.statistics.chartData[timeKey]
        row.c.push {v: value, f: bignumFilter(value)}
      @chart.data.rows.push row

    @chart.options = {
      title: "resources income"
      isStacked: "true"
      fill: 20
      displayExactValues: true
      vAxis: {
        title: "Amount"
        logScale: true
      }
      hAxis: {
        title: "Time"
      }
    }
    @chart.formatters = {}
    @chart
