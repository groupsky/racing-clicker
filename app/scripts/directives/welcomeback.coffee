'use strict'

###*
# @ngdoc directive
# @name swarmApp.directive:welcome-back
# @description
# # welcome-back
###
angular.module('swarmApp').directive 'welcomeBack', ($log, $interval, game, $location, $modal) ->
  restrict: 'E'
  link: ($scope) ->
    showWelcomeBack = (ignoreHeartbeat, reifiedToCloseDiffInSecs) ->
      $modalInstance = $modal.open({
        templateUrl: 'views/welcomeback.html'
        controller: 'WelcomeBackCtrl'
        resolve:
          ignoreHeartbeat: () ->
            ignoreHeartbeat
          durationSinceClosed: () ->
            $scope.durationSinceClosed
          reifiedToCloseDiffInSecs: () ->
            reifiedToCloseDiffInSecs
        })
    interval = null
    $scope.$on 'import', (event, args) ->
      $log.debug 'welcome back: import', args?.success, args
      if args?.success
        run true, true
    $scope.$on 'savedGameRecoveredFromFlash', (event, args) ->
      $log.debug 'welcome back: saved game recovered from flash'
      run()
    $scope.$on 'reset', (event, args) ->
      $scope.closeWelcomeBack?()?
    do run = (force=false, ignoreHeartbeat=false) ->
      # Show the welcome-back screen only if we've been gone for a while, ie. not when refreshing.
      # Do all time-checks for the welcome-back screen *before* scheduling heartbeats/onclose.
      $scope.durationSinceClosed = game.session.durationSinceClosed undefined, ignoreHeartbeat
      $scope.showWelcomeBack = $scope.durationSinceClosed.asMinutes() >= 3 or $location.search().forcewelcome
      reifiedToCloseDiffInSecs = (game.session.dateClosed(ignoreHeartbeat).getTime() - game.session.state.date.reified.getTime()) / 1000
      $log.debug 'time since game closed', $scope.durationSinceClosed.humanize(),
        millis:game.session.millisSinceClosed undefined, ignoreHeartbeat
        reifiedToCloseDiffInSecs:reifiedToCloseDiffInSecs

      showWelcomeBack(ignoreHeartbeat, reifiedToCloseDiffInSecs) if $scope.showWelcomeBack

      # Store when the game was closed. Try to use the browser's onclose (onunload); that's most precise.
      # It's unreliable though (crashes fail, cross-browser's icky, ...) so use a heartbeat too.
      # Wait until showWelcomeBack is set before doing these, or it'll never show
      $(window).unload -> game.session.onClose()
      interval ?= $interval (-> game.session.onHeartbeat()), 60000
      game.session.onHeartbeat() # game.session time checks after this point will be wrong
      if not $scope.showWelcomeBack
        $log.debug 'skipping welcome back screen: offline time too short', $scope.durationSinceClosed.asMinutes()
        return
