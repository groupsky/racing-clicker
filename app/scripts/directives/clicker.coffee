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

    working = false
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
      if not production.equals newProduction then newProduction else production
    , (newProd) ->
      production = newProd
      actionEffectPool.clearPool()

    $scope.$watch ->
      newPower = production.times(driving.stat 'critical.power', 100).times(''+Math.max(1, powerChance*3))
      if not powerProduction.equals newPower then newPower else powerProduction
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
      element.disabled = true
      e.preventDefault()
      e.stopPropagation()
      e.stopImmediatePropagation()
      e.returnValue = false
      if working
        $log.debug 'skipped'
        return false

      $log.debug 'click!'
      working = true

      roll = rng()
      chance = Math.min(powerChance, 0.34) + Math.log10(game.session.state.statistics.clicks+count)/50
      $log.debug "rolled #{roll}/#{chance}"

      if roll <= chance
        $log.debug "critical!"
        fame._addCount powerProduction

        if new Date().getTime() - e.timeStamp < 50
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

        if new Date().getTime() - e.timeStamp < 50
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

#      $timeout ->
      working = false
      element.disabled = false
#      , 0, false

