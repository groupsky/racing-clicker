'use strict'

###*
 # @ngdoc service
 # @name racingApp.Backfill
 # @description
 # # Backfill
 #
 # fix up old/broken save data at load time
###
angular.module('racingApp').factory 'Backfill', ($log, $q, $timeout) -> class Backfill
  run: (game) ->
    do =>
      @game = game
      [sM, sm, sp] = @game.session.state.version.saved.split('.').map (n) -> parseInt n

      if sM is 0 and sm < 7
        @fixTechUpgrades()
        @fixPriceChange "driving_upgrade"
        @fixPriceChange "autoclicker_upgrade"
        @fixPriceChange "sponsor_upgrades"
        @fixPriceChange "car_upgrade"

#        $q (resolve) => resolve @game.showBackfillProgress()
#        .then => @fixTechUpgrades()
#        .then => @fixPriceChange "driving_upgrade"
#        .then => @fixPriceChange "autoclicker_upgrade"
#        .then => @fixPriceChange "sponsor_upgrades"
#        .then => @fixPriceChange "car_upgrade"
#        .then => @game.closeBackfillProgress()

#  upgradeToResources: (upgrade, resources) ->
#    $log.debug "upgradeToResources defer", upgrade.name, resources[0].unit.name, resources[0].val+''
#    $q (resolve) =>
#      $timeout =>
#        $log.debug "upgradeToResources resolve", upgrade.name, resources[0].unit.name, resources[0].val+''
#        start = new Date().getTime()
#        while new Date().getTime()-start < 0.05
#          # until resources are over
#          return resolve(resources) if not _.every upgrade._totalCost(), (req) ->
#            for have in resources
#              if have.unit is req.unit
#                return req.val.lte have.val
#            true
#
#          upgrade._addCount 1
#
#          # consume the resources
#          _.every upgrade._totalCost(), (req) ->
#            for have in resources
#              if have.unit is req.unit
#                have.val = have.val.minus req.val
#
#        resolve @upgradeToResources upgrade, resources

  biSearch: (left, right, compare) ->
    while left.lt right
      mid = left.plus(right).divToInt(2)
      cmp = compare mid
      return mid if cmp is 0
      left = mid.plus(1) if cmp < 0
      right = mid.minus(1) if cmp > 0
    return right

  upgradeToResources: (upgrade, resources, maxLevel) ->
    max = 0
    angular.forEach resources, (res) =>
      max = Decimal.max max, @biSearch new Decimal(0), maxLevel, (lvl) ->
        upgrade._setCount lvl
        sufficient = _.every upgrade.totalCost(), (req) ->
          for have in resources
            if have.unit is req.unit
              return req.val.lte have.val
          return true

        return -1 if sufficient
        return 1
    upgrade._setCount max
    []


  releaseResources: (resources) ->
    $log.debug "releaseResources", resources
    for left in resources
      left.unit._addCount left.val


  fixPriceChange: (upgradeName) ->
    $log.debug "fixPriceChange #{upgradeName}"
    upgrade = @game.upgrade upgradeName
    oldCount = upgrade.count()
    overspent = upgrade.sumCost(oldCount, 1)
    upgrade._setCount(1)

    @releaseResources @upgradeToResources upgrade, overspent, oldCount

    $log.debug "#{upgradeName} decreased with ", oldCount.minus(upgrade.count()).toNumber()

#    @upgradeToResources(upgrade, overspent, oldCount)
#    .then(@releaseResources)
#    .then -> $log.debug "#{upgradeName} decreased with ", oldCount.minus(upgrade.count()).toNumber()


  fixTechUpgrades: ->
    $log.debug "fixTechUpgrades"
    @fixTechUpgrade("tech#{i}_prod", "tech#{i}_prod2") for i in [1..13]
#    $q.all(@fixTechUpgrade("tech#{i}_prod", "tech#{i}_prod2") for i in [1..13])

  fixTechUpgrade: (upgradeName, upgrade2Name) =>
#    $log.debug "fixTechUpgrade #{upgradeName}, #{upgrade2Name} defeer"
#    $q (resolve) =>
#      $timeout =>
    ret = null
    $log.debug "fixTechUpgrade #{upgradeName}, #{upgrade2Name} resolve"
    upgrade = @game.upgrade upgradeName
    count = upgrade.count()
    over = @game.session.state.upgrades[upgrade.name]?.minus count
    if over?.gt 0
      oldCount = @game.session.state.upgrades[upgrade.name]
      @game.session.state.upgrades[upgrade.name] = count
      overspent = upgrade.sumCost(oldCount.minus(count).toNumber(), count.toNumber())

      $log.debug "spent", overspent[0].val+''

      upgrade2 = @game.upgrade upgrade2Name
      @releaseResources @upgradeToResources upgrade2, overspent, oldCount
      $log.debug "#{upgradeName} decreased with ", oldCount.minus(upgrade.count()).minus(upgrade2.count()).toNumber()

#          ret = @upgradeToResources upgrade2, overspent
#          .then @releaseResources
#          .then -> $log.debug "#{upgradeName} decreased with ", oldCount.minus(upgrade.count()).minus(upgrade2.count()).toNumber()

#        resolve(ret)



#    # grant mutagen for old saves, created before mutagen existed
#    do ->
#      premutagen = game.unit 'premutagen'
#      ascension = game.unit 'ascension'
#      hatchery = game.upgrade 'hatchery'
#      expansion = game.upgrade 'expansion'
#      minlevelHatch = game.unit('invisiblehatchery').stat 'random.minlevel.hatchery'
#      minlevelExpo = game.unit('invisiblehatchery').stat 'random.minlevel.expansion'
#      # at minlevel hatcheries/expos, premutagen is always granted. if it wasn't - no ascensions and no premutagen -
#      # this must be an old save, they got the upgrades before mutagen existed.
#      if premutagen.count().isZero() and ascension.count().isZero() and (hatchery.count().greaterThanOrEqualTo(minlevelHatch) or expansion.count().greaterThanOrEqualTo(minlevelExpo))
#        $log.info 'backfilling mutagen for old save'
#        for up in [hatchery, expansion]
#          # toNumber is safe; old saves won't exceed 1e300 expansions/hatcheries
#          for i in [0...up.count().toNumber()]
#            for e in up.effect
#              e.onBuy new Decimal i + 1
#      else
#        $log.debug 'no mutagen backfill necessary'
#
#    # grant free respecs for all saves created before respecs existed
#    do ->
#      respec = game.unit('freeRespec')
#      if not respec.isCountInitialized()
#        respec._setCount respec.unittype.init
#
#    # restore lost ascension count. https://github.com/erosson/swarm/issues/431
#    do ->
#      ascension = game.unit('ascension')
#      stats = ascension.statistics()
#      if new Decimal(stats?.num ? 0).greaterThan(ascension.count()) and ascension.count().isZero()
#        $log.info 'backfill lost ascension tally', ascension.count()+'', stats.num
#        ascension._setCount stats.num

    $log.debug 'backfill success'

angular.module('racingApp').factory 'backfill', (Backfill) -> new Backfill()
