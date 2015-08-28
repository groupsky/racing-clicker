'use strict'

###*
 # @ngdoc service
 # @name racingApp.Fixy
 # @description
 # # Fixy
 # Service in the racingApp.
 #
###
angular.module('racingApp').factory 'Fixy', ($document, $log, $location) -> class Fixy
  constructor: ->
    @isFixHeight = _.contains window.location.search, 'fixheight'
  load: ->
    $document[0].body.className += " fix-height"


angular.module('racingApp').factory 'fixy', ($log, Fixy) ->
  ret = new Fixy()
  $log.debug 'isFixHeight:', ret.isFixHeight
  if ret.isFixHeight
    ret.load()
  return ret
