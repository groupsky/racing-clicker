'use strict'

###*
# @ngdoc directive
# @name swarmApp.directive:open-dialog
# @description
# # open-dialog
###
angular.module('swarmApp').directive 'openDialog', ($log, dialogService) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    scope.showDialog = () ->
      dialogService.openDialog(attrs.openDialog)
    element.bind('click', scope.showDialog)
