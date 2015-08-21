'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:action-effect
###
angular.module('swarmApp').directive 'actionEffect', ($log, $compile, $document, $rootScope, $timeout, $position, game) ->
  priority: -1
  link: (scope, element, attrs) ->
    body = $document.find('body').eq(0)

    showEffect = (modified) ->
      scope = $rootScope.$new()
      scope.modified = modified

      template = angular.element '''
          <div class="action-effect">
            <unit-resource ng-repeat="cost in modified track by cost.unit.name"
                           value="cost.val.absoluteValue()"
                           unit="cost.unit"
                           ng-class="{positive: !cost.val.isNegative(), negative: cost.val.isNegative()}"></unit-resource>
          </div>
        '''
      linker = $compile(template)

      tip = linker scope, (tip) ->
        $document.find('body').append tip
      tip.css
        top: 0
        left: 0
        display: 'block'
        position: 'absolute'

      position = $position.positionElements angular.element(element), tip, 'top', true
      position.top -= 25*modified.length
      position.top += 'px'
      position.left += 'px'
      tip.css position

      $timeout ->
        tip.remove()
      , 5000, false


    handleEvent = (args) ->
      return if args?.skipEffect
      modified = for name, cost of args.costs
        unit: game.unit(name)
        val: new Decimal(-1).times(cost)
      modified.unshift
        unit: game.unit(args.unitname)
        val: args.twinnum
      showEffect modified

    element.bind 'click', ->
      deregister1 = $rootScope.$on 'command', (event, args) ->
        deregister1()
        deregister2()
        deregister3()
        handleEvent args

      deregister3 = $rootScope.$on 'race', (event, args) ->
        deregister1()
        deregister2()
        deregister3()
        handleEvent args

      deregister2 = scope.$on '$destroy', ->
        deregister1()
        deregister3()
