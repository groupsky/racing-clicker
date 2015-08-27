'use strict'

###*
 # @ngdoc directive
 # @name racingApp.directive:tutorial
 # @description
 # # tutorial
###
angular.module('racingApp').directive 'tutorial', ($rootScope, $modal, game) ->
  modalInstance = null
  showWelcome = ->
    game.session.state.welcomeShowed = true
    modalInstance ?= $modal.open
      templateUrl: 'views/welcome.html'
      controller: ['$scope', '$modalInstance', 'game', ($scope, $modalInstance, game) ->
        $scope.close = -> $modalInstance.dismiss()
        $scope.game = game
        game.setGameSpeed 0
      ]
    modalInstance.result.finally -> game.setGameSpeed 1

  template: """
    <div ng-if="tutStep() > 0" class="alert animif alert-info" role="alert">
      <button ng-if="showCloseButton()" type="button" class="close" ng-click="close()"><span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>

      <div ng-if="tutStep() == 1" class='animif'>
        <p>Upgrading your car and buying new ones will bring you closer to the finish, allow you to earn fame (<strong>{{::game.unit('car1').type.label}}</strong> is just too much junk to get any fame or actual races) and most importantly hire other teams to race for you.</p>
        <p>Now go hire some <strong>{{::game.unit('tech1').type.plural}}</strong> to help you fix this pile of junk and maybe even earn enough bucks to buy some real wheels.</p>
      </div>
      <p ng-if="tutStep() == 2" class='animif'>Great job, now keep hiring mechanics until you get enough <strong><i class="icon-resource icon-technology"></i> technology</strong> to upgrade daddy's old <strong>{{::game.unit('car1').type.label}}</strong>.</p>
      <p ng-if="tutStep() == 3" class='animif'>Good now you have enough technology to upgrade this junk. Just wait to get the <strong><i class="icon-resource icon-money"></i> bucks</strong> for the upgrade</p>
      <p ng-if="tutStep() == 4" class='animif'>Time to upgrade...</p>
      <p ng-if="tutStep() == 5" class='animif'>Wow, this car really can drive! What's next - get some more upgrades.</p>
      <p ng-if="tutStep() == 6" class='animif'>Teaching all those <strong>{{::game.unit('tech1').type.plural}}</strong> gets a little tedious. Now let's see if we can do something about it.</p>
      <p ng-if="tutStep() == 6" class='animif'>Train a <strong>{{::game.unit('tech2').type.label}}</strong>.</p>
      <p ng-if="tutStep() == 7" class='animif'>Great, now the <strong>{{::game.unit('tech2').type.label}}</strong> will train <strong>{{::game.unit('tech1').type.plural}}</strong> for us.</p>
      <p ng-if="tutStep() == 7" class='animif'>Now let's get some real wheels. Start piling your resources for the lovely looking <strong>{{::game.unit('car2').type.label}}</strong>.</p>
      <p ng-if="tutStep() == 8" class='animif'>Yeah, now the racing can start! Click this shiny big button and earn some fame.</p>
      <p ng-if="tutStep() == 9" class='animif'>And some more...</p>
      <p ng-if="tutStep() == 10" class='animif'>Great, now keep racing until you get enough <strong><i class="icon-resource icon-fame"></i> fame</strong> to improve your <strong>{{::game.unit('tech1').type.plural}}</strong>.</p>
      <p ng-if="tutStep() == 11" class='animif'>Excellent, mechanics now produce much more technology.</p>
      <p ng-if="tutStep() == 11" class='animif'>Now checkout the sponsors. These are attracted to fame you know, and they give <strong><i class="icon-resource icon-money"></i> bucks</strong>. Let's try to find one.</p>
      <p ng-if="tutStep() == 11" class='animif'>Tip: upgrading your cars (except <strong>{{::game.unit('car1').type.label}}</strong>) will increase the fame you earn from racing.</p>
      <p ng-if="tutStep() == 12" class='animif'>This was just the basics. From now on you're on your own path of fame and glory.</p>
    </div>
  """
  scope:
    game: '=?'
  restrict: 'E'
  link: (scope, element, attrs) ->
    game_ = scope.game ?= game
    scope.showCloseButton = ->
      return scope.tutStep() == 12 or scope.tutStep() == 100
    scope.close = ->
      game.session.state.tutorialClosed = true
    scope.tutStep = ->
      return game.cache.tutorialStep ?= do =>
        if game.session.state.tutorialClosed
          return 0

        units = game_.countUnits()
        upgrades = game_.countUpgrades()

        if units.sponsor1.greaterThan(0)
          if units.car3.greaterThan(0) or units.sponsor1.greaterThan(1) or units.sponsor2.greaterThan(0) or units.tech3.greaterThan(0) or units.fame.greaterThan(1000000)
            game.session.state.tutorialClosed = true
            return 0
        if units.sponsor1.greaterThan(0)
          return 12
        if upgrades.tech1_prod.greaterThan(0)
          return 11
        if units.fame.greaterThan(7)
          return 10
        if units.fame.greaterThan(0)
          return 9
        if units.car2.greaterThan(0)
          return 8
        if units.tech2.greaterThan(0)
          return 7
        if upgrades.car1_upgrade.greaterThan(2)
          return 6
        if upgrades.car1_upgrade.greaterThan(0)
          return 5
        if units.money.greaterThanOrEqualTo(game.upgrade('car1_upgrade').costByName.money.val) and units.technology.greaterThanOrEqualTo(game.upgrade('car1_upgrade').costByName.technology.val)
          return 4
        if units.technology.greaterThanOrEqualTo(game.upgrade('car1_upgrade').costByName.technology.val)
          return 3
        if units.tech1.greaterThan(0)
          return 2
        if units.tech1.isZero()
          showWelcome() if not game.session.state.welcomeShowed
          return 1
