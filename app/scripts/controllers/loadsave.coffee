'use strict'

###*
 # @ngdoc function
 # @name swarmApp.controller:LoadsaveCtrl
 # @description
 # # LoadsaveCtrl
 # Controller of the swarmApp
 #
 # Loads a saved game upon refresh. If it fails, complain loudly and give the player a chance to recover their broken save.
###
angular.module('swarmApp').controller 'LoadSaveCtrl', ($scope, $log, game, session, version, $location, backfill, isKongregate, storage, saveId) ->
  $scope.form = {}
  $scope.isKongregate = isKongregate

  # http://stackoverflow.com/questions/14995884/select-text-on-input-focus-in-angular-js
  $scope.select = ($event) ->
    $event.target.select()

  $scope.contactUrl = ->
    "#/contact?#{$.param error:$scope.form.error}"

  try
    exportedsave = session.getStoredSaveData()
  catch e
    $log.error "couldn't even read localstorage! oh no!", e
    game.reset true
    # show a noisy freakout message at the top of the screen with the exported save
    $scope.form.errored = true
    $scope.form.error = e.message
    $scope.form.domain = window.location.host
    # tell analytics
    $scope.$emit 'loadGameFromStorageFailed', e.message
    return

#  game.reset true
#  return

  try
    session.load()
    $log.debug 'Game data loaded successfully.', this
  catch e
    # Couldn't load the user's saved data.
    if not exportedsave
      # If this is their first visit to the site, that's normal, no problems
      $log.debug "Empty saved data; probably the user's first visit here. Resetting quietly."
      game.reset true #but don't save, in case we're waiting for flash recovery
      # listen for flash to load - loading it takes extra time, but we might find a save there.
      storage.flash.onReady.then ->
        encoded = storage.flash.getItem saveId
        if encoded
          $log.debug "flash loaded successfully, and found a saved game there that wasn't in cookies/localstorage! importing."
          # recovered save from flash! tell analytics
          $scope.$root.$broadcast 'savedGameRecoveredFromFlash', e.message
          game.importSave encoded, true # don't save when recovering from flash - if this is somehow a mistake, player can take no action
        else
          $log.debug 'flash loaded successfully, but no saved game found. this is truly a new visitor.'
    else
      # Couldn't load an actual real save. Shit.
      $log.warn "Failed to load non-empty saved data! Oh no!"
      # reset, but don't save after resetting. Try to keep the bad data around unless the player takes an action.
      game.reset true
      # show a noisy freakout message at the top of the screen with the exported save
      $scope.form.errored = true
      $scope.form.error = e.message
      $scope.form.export = exportedsave
      # tell analytics
      $scope.$emit 'loadGameFromStorageFailed', e.message

  # try to load a save file from the url.
  if (savedata = $location.search().savedata)?
    $log.info 'loading game from url...'
    # transient=true: don't overwrite the saved data until we buy something
    game.importSave savedata, true
    $log.info 'loading game from url successful!'

  backfill.run game

angular.module('swarmApp').controller 'AprilFoolsCtrl', ($scope, options) ->
  $scope.options = options

angular.module('swarmApp').controller 'WelcomeBackCtrl', ($scope, game, $log, ignoreHeartbeat, durationSinceClosed, $modalInstance) ->
  $scope.closeWelcomeBack = ->
    $log.debug 'closeWelcomeBack'
    $modalInstance.dismiss()
    return undefined #quiets an angular error

  reifiedToCloseDiffInSecs = (game.session.dateClosed(ignoreHeartbeat).getTime() - game.session.state.date.reified.getTime()) / 1000
  $log.debug 'time since game closed', durationSinceClosed.humanize(),
    millis:game.session.millisSinceClosed undefined, ignoreHeartbeat
    reifiedToCloseDiffInSecs:reifiedToCloseDiffInSecs

  # show all tab-leading units, and three leading generations of meat
  interestingUnits = []
  leaders = 0
  for unit in game.tabs.byName.technology.sortedUnits
    if leaders >= 3
      break
    if !unit.velocity().isZero()
      leaders += 1
      interestingUnits.push unit
  interestingUnits = interestingUnits.concat _.map game.tabs.list, 'leadunit'
  uniq = {}
  $scope.offlineGains = _.map interestingUnits, (unit) ->
    if not uniq[unit.name]
      uniq[unit.name] = true
      countNow = unit.count()
      countClosed = unit._countInSecsFromReified reifiedToCloseDiffInSecs
      countDiff = countNow.minus countClosed
      if countDiff.greaterThan 0
        return unit:unit, val:countDiff
  $scope.offlineGains = (g for g in $scope.offlineGains when g)
