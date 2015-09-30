'use strict'

###*
 # @ngdoc service
 # @name racingApp.Backfill
 # @description
 # # Backfill
 #
 # fix up old/broken save data at load time
###
angular.module('racingApp').factory 'Backfill', ($log) -> class Backfill
  run: (game) ->
    do ->
      [sM, sm, sp] = game.session.state.version.saved.split('.').map (n) -> parseInt n

      if sM is 0 and sm is 5
        @fixTechUpgrades game

  fixTechUpgrades: (game) ->
    for i in [1..13]
      upgrade = game.upgrade "tech#{i}_prod"
      count = upgrade.count()
      over = game.session.state.upgrades[upgrade.name]?.minus count
      if over?.gt 0
        oldCount = game.session.state.upgrades[upgrade.name]
        game.session.state.upgrades[upgrade.name] = count
        overspent = upgrade.sumCost(oldCount.minus(count).toNumber(), count.toNumber())

        $log.debug "spent", overspent[0].val+''

        upgrade2 = game.upgrade "tech#{i}_prod2"
        upgrade2._addCount(1) while _.every upgrade2._totalCost(), (req) ->
          for have in overspent
            if have.unit is req.unit
              if req.val.gt have.val
                return false
              have.val = have.val.minus req.val
              return true
          return false

        $log.debug "left to spent", overspent[0].val+''

        for left in overspent
          left.unit._addCount left.val

        $log.debug "decreased with ", oldCount.minus(upgrade2.count()).toNumber()




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
