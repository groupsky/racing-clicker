'use strict'

###*
 # @ngdoc service
 # @name swarmApp.dialogService
 # @description
 # # dialogService
 #
###
angular.module('swarmApp').service 'dialogService', ($rootScope, $log, $modal, $controller) -> new class DialogService
  constructor: ->
    @dialogs =
      options:
        template: 'views/options.html'
        controller: 'OptionsCtrl'
      achievements:
        template: 'views/achievementsdialog.html'
        controller: 'AchievementsCtrl'
      statistics:
        template: 'views/statistics.html'
        controller: 'StatisticsCtrl'
  openDialog: (name) ->
    controllerScope = $rootScope.$new()
    controllerScope.closeDialog = () ->
      controllerScope.modalInstance.dismiss()
    $controller(@dialogs[name].controller, {$scope: controllerScope})
    controllerScope.modalInstance = $modal.open({
      templateUrl: @dialogs[name].template
      scope: controllerScope
      size: 'lg'
      })
