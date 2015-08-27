'use strict'

###*
 # @ngdoc directive
 # @name racingApp.directive:unit
 # @description
 # # unit
###
angular.module('racingApp').directive 'unit', ($log, game, commands, options, util, $location, parseNumber) ->
  templateUrl: 'views/unit.html'
  restrict: 'E'
  scope:
    unit: '='
  link: (scope, element, attrs) ->
    scope.game = game
    scope.commands = commands
    scope.options = options
    scope.velocityUnit = options.getVelocityUnit({prod: scope.unit})

    search = $location.search()
    if search.num?
      scope.form.buyCount = search.num
    else if search.twinnum?
      # legacy format - our code doesn't use `?twinnum=n` anymore, but it used to. some users might still use it.
      scope.form.buyCount = "=#{search.twinnum}"

    _buyCount = Decimal.ONE
    scope.buyCount = ->
      parsed = parseNumber(scope.form.buyCount or '1', scope.unit) ? Decimal.ONE
      # caching required for angular
      if not parsed.equals _buyCount
        _buyCount = parsed
      return _buyCount

    scope.filterVisible = (upgrade) ->
      upgrade.isVisible()

    scope.$watch ->
      for upgrade in scope.unit.upgrades.byClass.upgrade ? []
        if upgrade.isVisible()
          return true
      false
    , (has_upgrades) -> scope.has_upgrades = has_upgrades

    scope.unitCostAsPercent = (unit, cost) ->
      MAX = new Decimal 9999.99
      count = cost.unit.count()
      if count.lessThanOrEqualTo 0
        return MAX
      num = Decimal.max 1, unit.maxCostMet()
      Decimal.min MAX, cost.val.times(num).dividedBy(count)

    scope.unitCostAsPercentOfVelocity = (unit, cost) ->
      MAX = new Decimal 9999.99
      count = cost.unit.velocity()
      if count.lessThanOrEqualTo 0
        return MAX
      Decimal.min MAX, cost.val.times(unit.maxCostMetOfVelocity()).dividedBy(count)

    scope.description = (resource, desc=resource.descriptionFn) ->
      # this makes descriptions a potential xss vector. careful to only use numbers.
      desc scope
