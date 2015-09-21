'use strict'

###*
 # @ngdoc service
 # @name racingApp.service:endgame
 # @description
 # # endgame
###
angular.module('racingApp').service 'endgame', ($rootScope, dialogService) ->
  console.info 'endGame'
  $rootScope.$on 'command', (event, cmd) ->
    console.info 'endGame', cmd
    if cmd.upgradename is 'car10_buy'
      dialogService.openDialog('endgame')
