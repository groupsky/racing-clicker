
angular.module('racingApp').controller 'ChartCtrl', ($scope, $log, game, options) ->
  $scope.game = game
  $scope.options = options

  $scope.prodchart = prodchart =
    type: 'PieChart'

  # https://developers.google.com/chart/interactive/docs/gallery/piechart#Configuration_Options
  textStyle =
    color: $('body').css 'color'
    fontName: $('body').css 'font'
    fontSize: $('body').css 'font-size'
  prodchart.options =
    backgroundColor: $('body').css 'background-color'
    titleTextStyle: textStyle
    fontName: textStyle.fontName
    fontSize: textStyle.fontSize
    chartArea:
      backgroundColor: $('body').css 'background-color'
    pieSliceBorderColor: $('body').css 'background-color'
    pieResidueSliceLabel: 'Other' #by default, this is translated to the browser language - inconsistent with the rest of the game
    legend:
      position: 'labeled'
      textStyle: textStyle
    # this overlays slice colors, some themes are unreadable that way. use the default white.
    pieSliceTextStyle: _.omit textStyle, 'color'
    #displayExactValues: false
    #is3D: true
    title: 'Production Rates'
    sliceVisibilityThreshold: 0.01
    # tooltips refuse to display bignums properly, so don't show it at all
    tooltip: {trigger:'none'}

  unit = $scope.unit
  totalVelocity = unit.velocity()
  $scope.updatecharts = ->
    $log.debug "updating chart data"
    #populate data.. move this to function so it can update.
    # also need to get the 'correct' units
    prodchart.data = [ ["Unit Name", "Production" ] ]
    for u in $scope.game.unitlist()
      if u.isVisible() and not u.count().isZero() and unit.name of u.totalProduction()
        #$log.debug unit
        #need Number() for full pie.. will die with bignumbers!!!
        prodchart.data.push [u.type.label, u.totalProduction()[unit.name].dividedBy(totalVelocity).toNumber()]

  # this works since you can't buy territory units with the chart visible
  $scope.updatecharts()
