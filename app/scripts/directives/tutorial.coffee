'use strict'

###*
 # @ngdoc directive
 # @name swarmApp.directive:tutorial
 # @description
 # # tutorial
###
angular.module('swarmApp').directive 'tutorial', ($rootScope, $modal, game) ->
  modalInstance = null
  showWelcome = ->
    game.session.state.welcomeShowed = true
    modalInstance ?= $modal.open
      templateUrl: 'views/welcome.html'
      controller: ($scope, $modalInstance, game) ->
        $scope.close = -> $modalInstance.dismiss()
        $scope.game = game
        game.setGameSpeed 0
    modalInstance.result.finally -> game.setGameSpeed 1

  template: """
    <div ng-if="tutStep() > 0" class="alert animif alert-info" role="alert">
      <button ng-if="showCloseButton()" type="button" class="close" ng-click="close()"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>

      <div ng-if="tutStep() == 1">
        <p>Upgrading your car and buying new ones will bring you closer to the finish, allow you to earn fame (<strong>{{::game.unit('car1').type.label}}</strong> is just too much junk to get any fame or actual races) and most importantly hire other teams to race for you.</p>
        <p>Now go hire some <strong>{{::game.unit('tech1').type.plural}}</strong> to help you fix this pile of junk and maybe even earn enough bucks to buy some real wheels.</p>
      </div>
      <p ng-if="tutStep() == 2">Great job, now keep hiring mechanics until you get enough <strong><i class="icon-resource icon-technology"></i> technology</strong> to upgrade daddy's old <strong>{{::game.unit('car1').type.label}}</strong>.</p>
      <p ng-if="tutStep() == 3">Good now you have enough technology to upgrade this junk. Just wait to get the <strong><i class="icon-resource icon-money"></i> bucks</strong> for the upgrade</p>
      <p ng-if="tutStep() == 4">Time to upgrade...</p>
      <p ng-if="tutStep() == 5">Wow, this car really can drive! What's next - get some more upgrades.</p>
      <p ng-if="tutStep() == 6">Good, now start piling your cash for the lovely looking <strong>{{::game.unit('car2').type.label}}</strong>.</p>
      <p ng-if="tutStep() == 7">Yeah, now the racing can start! Click this shiny big button and earn some fame.</p>
      <p ng-if="tutStep() == 8">And some more...</p>
      <p ng-if="tutStep() == 9">What is fame good for? You can invest it in finding new sponsors to increase your bucks, or train your <strong>{{::game.unit('tech1').type.label}}</strong> to produce more <strong><i class="icon-resource icon-technology"></i> technology</strong>.</p>
    </div>
  """
  scope:
    game: '=?'
  restrict: 'E'
  link: (scope, element, attrs) ->
    game_ = scope.game ?= game
    scope.showCloseButton = ->
      return scope.tutStep() == 9 or scope.tutStep() == 100
    scope.close = ->
      game.session.state.tutorialClosed = true
    scope.tutStep = ->
      return game.cache.tutorialStep ?= do =>
        units = game_.countUnits()
        upgrades = game_.countUpgrades()

        if units.car3.greaterThan(0) or upgrades.car2_upgrade.greaterThan(1) or game.session.state.tutorialClosed
          return 0
        if units.fame.greaterThan(7)
          return 9
        if units.fame.greaterThan(0)
          return 8
        if units.car2.greaterThan(0)
          return 7
        if upgrades.car1_upgrade.greaterThan(4)
          return 6
        if upgrades.car1_upgrade.greaterThan(0)
          return 5
        if units.money.greaterThanOrEqualTo(game.upgrade('car1_upgrade').costByName.money.val)
          return 4
        if units.tech1.greaterThan(9)
          return 3
        if units.tech1.greaterThan(0)
          return 2
        if units.tech1.isZero()
          showWelcome() if not game.session.state.welcomeShowed
          return 1
