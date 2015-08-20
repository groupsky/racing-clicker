angular.module('swarmApp').filter 'default', ->
  (value, def) ->
    value ? def
