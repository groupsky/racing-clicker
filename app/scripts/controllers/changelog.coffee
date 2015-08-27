'use strict'

###*
 # @ngdoc function
 # @name racingApp.controller:ChangelogCtrl
 # @description
 # # ChangelogCtrl
 # Controller of the racingApp
###
angular.module('racingApp').controller 'ChangelogCtrl', ($log, $scope, env, version) ->
  $scope.$emit 'changelog'
  $scope.env = env
  zone = -8
  $scope.changestats =
    _rawheaders: $ '.changelog h4'
    lastHeaders: (days) ->
      _.filter $scope.changestats.headers, (header) ->
        header.diffDays < days

  parseheader = (header) ->
    text = $(header).text()
    [ver, datestr] = text.split ' '
    date = moment(datestr, 'YYYY/MM/DD').zone zone
    diffDays = moment().zone(zone).diff date, 'days'
    text: text
    version: ver
    date: date
    diffDays: diffDays
  $scope.changestats.headers = (parseheader(header) for header in $scope.changestats._rawheaders)
  [$scope.changestats.lastrelease, ..., $scope.changestats.firstrelease] = $scope.changestats.headers
  $scope.changestats.days = $scope.changestats.firstrelease?.diffDays
  $log.debug 'changelogdate', $scope.changestats
