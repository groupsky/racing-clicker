'use strict'

###*
 # @ngdoc service
 # @name racingApp.feedback
 # @description
 # # feedback
 # Factory in the racingApp.
###
angular.module('racingApp').factory 'feedback', ($log, game, version, env, isKongregate) -> new class Feedback
  # other alternatives: pastebin (rate-limited), github gist
  # tinyurl doesn't allow cross-site requests
  createTinyurl: (exported=game.session.exportSave()) ->
    game.cache.tinyUrl[exported] ?= do =>
      if isKongregate()
        load_url = "https://racing-clicker.github.io?kongregate=1&fixheight=1/importsplash?savedata=#{encodeURIComponent exported}"
      else
        load_url = "https://racing-clicker.github.io/importsplash?savedata=#{encodeURIComponent exported}"
      jQuery.ajax("https://www.googleapis.com/urlshortener/v1/url?key=#{env.googleApiKey}",
        type: 'POST'
        data:JSON.stringify
          longUrl: load_url
        contentType:'application/json'
        dataType:'json')
        .done (data, status, xhr) =>
          $log.debug 'createTinyurl success', data, status, xhr
        .fail (data, status, xhr) =>
          $log.debug 'createTinyurl fail ', data, status, xhr
