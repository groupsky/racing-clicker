angular.module('racingApp').filter 'default', ->
  (value, def) ->
    value ? def
