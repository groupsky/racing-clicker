'use strict'

###*
 # @ngdoc service
 # @name racingApp.service:endgame
 # @description
 # # endgame
###
angular.module('racingApp').service 'endgame', ($rootScope, dialogService, game) ->
  console.info 'endGame'
  $rootScope.$on 'achieve', ->
    dialogService.openDialog('endgame') if game.achievementPoints() >= game.achievementPointsPossible
