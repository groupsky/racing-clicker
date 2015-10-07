'use strict'

###*
 # @ngdoc directive
 # @name racingApp.directive:clicker
 # @description
 # # clicker
###
angular.module('racingApp').directive 'clicker', ($rootScope, $timeout, game) ->
  templateUrl: 'views/clicker.html'
  restrict: 'E'
  scope:
    game: '=?'
  controllerAs: 'clickerCtrl'
  controller: ($log, $scope, commands) ->
    savePromise = false
    game_ = $scope.game ? game

    $scope.game = game_
    $scope.units = game_.units()
    $scope.race = $scope.units.race
    $scope.races = $scope.units.races
    $scope.driving = $scope.units.driving
    $scope.fame = game.unit('fame')
    $scope.filterVisible = (upgrade) -> upgrade.isVisible()


angular.module('racingApp').directive 'clickero', ($rootScope, $timeout, game, ActionEffectPool, seedrand, $log) ->
  restrict: 'A'
  priority: -100
  link: ($scope, element, attrs) ->
    actionEffectPool = new ActionEffectPool()
    powerActionEffectPool = new ActionEffectPool
      actionClass: "action-critical"

    savePromise = false
    aggregated = new Decimal 0
    count = 0
    start = false

    fame = game.unit('fame')
    driving = game.unit('driving')
    production = new Decimal(0)
    powerProduction = new Decimal(0)
    powerChance = 0.01
    rng = null

    $scope.$watch ->
      newProduction = driving.totalProduction().fake_fame
      if production.equals newProduction
        return production
      else
        return newProduction
    , (newProd) ->
      production = newProd
      actionEffectPool.clearPool()

    $scope.$watch ->
      base = 10
      base += game.session.state.statistics.byUnit.fame.cps if game.session.state.statistics.byUnit.fame? and game.session.state.statistics.byUnit.fame.cps
      newPower = production.times(driving.stat('critical.power', 100).plus(''+base)).times(Decimal.max(1, ''+(powerChance*3)))
      if powerProduction.equals newPower then return powerProduction else return newPower
    , (power) ->
      powerProduction = power
      powerActionEffectPool.clearPool()

    $scope.$watch ->
      chance = new Decimal(driving.stat 'critical.chance', 1).toNumber()/100
      chance += game.session.state.statistics.byUnit.fame.cps/256 if game.session.state.statistics.byUnit.fame? and game.session.state.statistics.byUnit.fame.cps
      return chance
    , (chance) ->
      powerChance = chance
      # consistent random seed. No savestate scumming.
      game.session.state.date.restarted ?= game.session.state.date.started
      seed = "[#{game.session.state.date.restarted.getTime()}, clicker, #{chance}]"
      rng = seedrand.rng seed

    element.bind 'touchend mouseup keyup pointerup', (e) ->
      roll = rng()
      chance = Decimal.min(''+powerChance, 0.34).plus(Decimal.log(game.session.state.statistics.clicks+count, 10).div(50)).toNumber()
      $log.debug "rolled #{roll}/#{chance}"

      if roll <= chance
        $log.debug "critical!"
        fame._addCount powerProduction

        powerActionEffectPool.button = angular.element(element)
        powerActionEffectPool.handleEvent
          unit: fame
          unitname: fame.name
          num: powerProduction
          twinnum: powerProduction
          costs: {}

        aggregated = aggregated.plus(powerProduction)
      else
        fame._addCount production

        actionEffectPool.button = angular.element(element)
        actionEffectPool.handleEvent
          unit: fame
          unitname: fame.name
          num: production
          twinnum: production
          costs: {}

        aggregated = aggregated.plus(production)

      count += 1
      start = new Date().getTime() if not start
      end = new Date().getTime()

      $timeout.cancel savePromise if savePromise
      savePromise = $timeout ->
        game.save()
        $rootScope.$emit "command",
          name: 'race'
          unit: fame
          unitname: fame.name
          now: game.now
          elapsed: game.elapsedStartMillis()
          attempt: aggregated
          num: aggregated
          twinnum: aggregated
          costs: {}
          skipEffect: true
          clicks: count
          cps: if count > 1 then count*1000.0/(end-start) else count
        aggregated = new Decimal 0
        count = 0
        start = false
        end = false
      , 1500

