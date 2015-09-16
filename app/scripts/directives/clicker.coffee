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


angular.module('racingApp').directive 'clickero', ($rootScope, $timeout, game, ActionEffectPool) ->
  restrict: 'A'
  priority: -100
  link: ($scope, element, attrs) ->
    actionEffectPool = new ActionEffectPool()

    working = false
    savePromise = false
    aggregated = new Decimal 0
    count = 0
    start = false

    fame = game.unit('fame')
    driving = game.unit('driving')
    production = driving.totalProduction().fake_fame

    $scope.$watch ->
      newProduction = driving.totalProduction().fake_fame
      if not production.equals newProduction then newProduction else production
    , (newProd) ->
      production = newProd
      actionEffectPool.clearPool()

    element.bind 'click', (e) ->
      element.disabled = true
      if not working
        console.warn 'click!'
        actionEffectPool.button = angular.element(element)
        working = true

        fame._addCount production

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

        $timeout ->
          working = false
          element.disabled = false
        , 50, false



      e.preventDefault()
      e.stopPropagation()
      e.stopImmediatePropagation()
      e.returnValue = false

