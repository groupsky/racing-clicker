'use strict'

###*
# @ngdoc directive
# @name swarmApp.directive:resource
# @description
# # resource
###
angular.module('swarmApp').directive 'resource', ->
  templateUrl: 'views/resource.html'
  scope:
    name: '@',
    value: '=?',
    velocity: '=?'
    units: '=?'
    label: '@?'
    plural: '@?'
    suffix: '@?'
    filter: '@?'
    filterOpts: '=?'
  restrict: 'E'
  compile: (element, attrs) ->
    attrs.filter ?= 'bignum'

angular.module('swarmApp').directive 'unitResource', (options) ->
  template: """
    <div class="unit-resource unit-{{unit.name}}">
      <resource
        name="{{unit.name}}"
        value="value | default:unit.count()"
        velocity="hideVelocity?false:unit.velocity()"
        units="units"
        label="{{unit.unittype.label}}"
        plural="{{unit.unittype.plural}}"
        suffix="{{unit.suffix}}"></resource>
    </div>
  """
  scope:
    unit: '='
    value: '=?'
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.units = options.getVelocityUnit {unit: scope.unit}
    scope.hideVelocity = scope.value?
