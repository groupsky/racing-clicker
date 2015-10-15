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
        templateUrl: 'views/options.html'
        controller: 'OptionsCtrl'
      achievements:
        templateUrl: 'views/achievementsdialog.html'
        controller: 'AchievementsCtrl'
      statistics:
        templateUrl: 'views/statistics.html'
        controller: 'StatisticsCtrl'
      feedback:
        templateUrl: 'views/contact.html'
        controller: 'ContactCtrl'
      changelog:
        templateUrl: 'views/changelog.html'
      endgame:
        templateUrl: 'views/endgame.html'
        size: 'md'
      importsplash:
        templateUrl: 'views/importsplash.html'
        controller: 'ImportsplashCtrl'
        size: 'md'
      ascend:
        templateUrl: 'views/ascend.html',
        controller: 'AscendCtrl',
        size: 'md'
      backfillProgress:
        templateUrl: 'views/backfillprogress.html'
        size: 'sm'
        backdrop: 'static'
  openDialog: (name) ->
    controllerScope = $rootScope.$new()
    controllerScope.closeDialog = () ->
      controllerScope.modalInstance.dismiss()
    if(@dialogs[name].controller)
      $controller(@dialogs[name].controller, {$scope: controllerScope})
    controllerScope.modalInstance = $modal.open(angular.extend({
      scope: controllerScope
      size: 'lg'
      }, @dialogs[name]))
