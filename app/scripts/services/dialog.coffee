'use strict'

###*
 # @ngdoc service
 # @name racingApp.dialogService
 # @description
 # # dialogService
 #
###
angular.module('racingApp').service 'dialogService', ($rootScope, $log, $modal, $controller) -> new class DialogService
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
      feedback:
        template: 'views/contact.html'
        controller: 'ContactCtrl'
      changelog:
        template: 'views/changelog.html'
      endgame:
        template: 'views/endgame.html'
        size: 'md'
      importsplash:
        template: 'views/importsplash.html'
        controller: 'ImportsplashCtrl'
        size: 'md'
      ascend:
        template: 'views/ascend.html',
        controller: 'AscendCtrl',
        size: 'md'
  openDialog: (name) ->
    controllerScope = $rootScope.$new()
    controllerScope.closeDialog = () ->
      controllerScope.modalInstance.dismiss()
    if(@dialogs[name].controller)
      $controller(@dialogs[name].controller, {$scope: controllerScope})
    controllerScope.modalInstance = $modal.open({
      templateUrl: @dialogs[name].template
      scope: controllerScope
      size: @dialogs[name].size ? 'lg'
      })
