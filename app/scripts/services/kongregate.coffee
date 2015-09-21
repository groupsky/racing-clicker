'use strict'

###*
 # @ngdoc service
 # @name racingApp.Kongregate
 # @description
 # # Kongregate
 # Service in the racingApp.
 #
 # http://developers.kongregate.com/docs/api-overview/client-api
###
angular.module('racingApp').factory 'isKongregate', ->
  return ->
    # use the non-# querystring to avoid losing it when the url changes. $location.search() won't work.
    # a simple string-contains is hacky, but good enough as long as we're not using the querystring for anything else.
    _.contains window.location.search, 'kongregate'
    # alternatives:
    # - #-querystring is overwritten on reload.
    # - url is hard to test, and flaky with proxies.
    # - separate deployment? functional, but ugly maintenance.
    # - when-framed-assume-kongregate? could work...
    # - hard-querystring (/?kongregate#/tab/meat) seems to work well! can't figure out how to get out of it in 30sec.

angular.module('racingApp').factory 'Kongregate', (isKongregate, $log, $location, game, $rootScope, $interval, options, $q, loginApi, env) -> class Kongregate
  constructor: ->
  isKongregate: ->
    isKongregate()
  load: ->
    $log.debug 'loading kongregate script...'
    onLoad = $q.defer()
    @onLoad = onLoad.promise
    @onLoad.then => @_onLoad()
    try
      @kongregate = window.parent.kongregate
      @parented = window.parent.document.getElementsByTagName('iframe')[0]
    catch e
      # pass - no kongregate_shell.html, or kongregate api's blocked in it. try to load the api ourselves
    if @kongregate
      $log.debug 'kongregate api loaded from parent frame'
      onLoad.resolve()
      return
    $.getScript 'https://cdn1.kongregate.com/javascripts/kongregate_api.js'
      .done (script, textStatus, xhr) =>
        $log.debug 'kongregate script loaded, now trying to load api', window.kongregateAPI
        # loadAPI() requires an actual kongregate frame, `?kongregate=1` in its own tab is insufficient. fails silently.
        window.kongregateAPI.loadAPI =>
          $log.debug 'kongregate api loaded'
          @kongregate = window.kongregateAPI.getAPI()
          onLoad.resolve()
      .fail (xhr, settings, exception) =>
        $log.error 'kongregate load failed', xhr, settings, exception
        onLoad.reject()

  onResize: -> #overridden on load
  _onResize: -> #overridden on load
  _resizeGame: (w, h) ->
    @kongregate.services.resizeGame Math.max(options.iframeMinX(), w ? 0), Math.max(options.iframeMinY(), h ? 0)
    if @parented
      # kongregate resizes its shell instead of my game. scroll lock demands my game have the scrollbar, not the iframe.
      h = @parented.style.height
      w = @parented.style.width
      @parented.style.height = '100%'
      @parented.style.width = '100%'
      document.documentElement.style.height = h
      document.documentElement.style.width = w
  onScrollOptionChange: (noresizedefault, oldscroll) ->
    scrolling = options.scrolling()
    $log.debug 'updating kong scroll option', scrolling

    # if scrolling == 'resize'
    #   # no blinking scrollbar on resize. https://stackoverflow.com/questions/2469529/how-to-disable-scrolling-the-document-body
    #   document.body.style.overflow = 'hidden'
    #   @onResize = @_onResize
    #   # selecting autoresize should always trigger a resize
    #   @onResize true
    # else
    #   document.body.style.overflow = ''
    #   @onResize = ->
    #
    # if scrolling == 'lockhover'
    #   @bindLockhover()
    # else
    #   @unbindLockhover()
    #
    # if scrolling != 'resize' and oldscroll == 'resize' and @isLoaded and not noresizedefault
    #   @_resizeGame null, null

    @bindLockhover()

  unbindLockhover: ->
    $('html').off 'DOMMouseScroll mousewheel'
  bindLockhover: ->
    # heavily based on https://stackoverflow.com/questions/5802467/prevent-scrolling-of-parent-element
    # body = $('body')[0]
    # $both = $('body,html')
    $(document).on 'DOMMouseScroll mousewheel', '.scrollable', (ev) ->
      $this = $(this)
      scrollTop = this.scrollTop
      scrollHeight = this.scrollHeight
      height = $this.height()
      #height = $this.outerHeight true
      # height = window.innerHeight
      if ev.type == 'DOMMouseScroll'
        delta = ev.originalEvent.detail * -40
      else
        delta = ev.originalEvent.wheelDelta
      up = delta > 0
      # not even log.debugs; scroll events are performance-sensitve.
      # console.log 'mousewheelin', delta, up, scrollTop, scrollHeight, height

      prevent = ->
        ev.stopPropagation()
        ev.preventDefault()
        ev.returnValue = false
        return true

      # console.log 'mousewheelin check down', !up, -delta, scrollHeight - height - scrollTop
      # console.log 'mousewheelin check up', up, delta, scrollTop
      if !up && -delta > scrollHeight - height - scrollTop
        # console.log 'mousewheelin blocks down', delta, up
        # Scrolling down, but this will take us past the bottom.
        $this.scrollTop scrollHeight
        return prevent()
      else if up && delta > scrollTop
        # Scrolling up, but this will take us past the top.
        # console.log 'mousewheelin blocks up', delta, up
        $this.scrollTop(0)
        return prevent()

  # Login to swarmsim using Kongregate userid/token as credentials.
  _swarmApiLogin: ->
    if not env.isServerBackendEnabled
      return
    doLogin = =>
      $log.debug 'kongregate swarmapi login...'
      loginApi.login 'kongregate',
        user_id: @kongregate.services.getUserId()
        game_auth_token: @kongregate.services.getGameAuthToken()
        # not needed for auth, but updates visible username
        username: @kongregate.services.getUsername()
      .success (data, status, xhr) ->
        $log.debug 'kongregate swarmapi login success', data, status, xhr
      .error (data, status, xhr) ->
        $log.debug 'kongregate swarmapi login error', data, status, xhr
    if @kongregate.services.isGuest()
      $log.debug 'kongregate swarmapi guest login...'
      loginApi.login 'guestuser'
      .success (data, status, xhr) ->
        $log.debug 'kongregate swarmapi guest login success', data, status, xhr
      .error (data, status, xhr) ->
        $log.debug 'kongregate swarmapi guest login error', data, status, xhr
    else
      doLogin()
    # upgrade guest logins later
    @kongregate.services.addEventListener 'login', doLogin

  _onLoad: ->
    $log.debug 'kongregate successfully loaded!', @kongregate
    @isLoaded = true
    @reportStats()

    @_swarmApiLogin()

    Raven.setUser
      id: @kongregate.services.getUsername()

    # configure resizing iframe
    html = $(document.documentElement)
    body = $(document.body)
    oldheight = null
    olddate = new Date 0
    @_onResize = (force) =>
      #height = Math.max html.height(), body.height(), 600
      height = Math.max body.height(), 600
      if height != oldheight or force
        date = new Date()
        datediff = date.getTime() - olddate.getTime()
        # jumpy height changes while rendering, especially in IE!
        # throttle height decreases to 1 per second, to avoid some of the
        # jumpiness. height increases must be responsive though, so don't
        # throttle those. seems to be enough. (if this proves too jumpy, could
        # add a 100px buffer to size increases, but not necessary yet I think.)
        if height > oldheight or (datediff >= 1000 and oldheight - height > 100) or force
          $log.debug "onresize: #{oldheight} to #{height} (#{if height > oldheight then 'up' else 'down'}), #{datediff}ms"
          oldheight = height
          olddate = date
          @_resizeGame 800, height
          if @parented
            @parented.style.height = height+'px'
    @onScrollOptionChange true
    # resize whenever size changes.
    #html.resize onResize
    # NOPE. can't detect page height changes with standard events. header calls onResize every frame.
    $log.debug 'setup onresize'

  reportStats: ->
    try
      if not @isLoaded or not game.session.state.kongregate
        return
      # don't report more than once per minute
      now = new Date()
      if @lastReported and now.getTime() < @lastReported.getTime() + 60 * 1000
        return
      #if not @lastReported
      #  @kongregate.stats.submit 'Initialized', 1
      @lastReported = now
      @kongregate.stats.submit 'Racing Upgrades', @_count game.upgrade 'driving_upgrade'
      @kongregate.stats.submit 'Cars Bought', @_countBought(game.tabs.byName.money.units)-1
      @kongregate.stats.submit 'Racer Level', @_count game.upgrade 'autoclicker_upgrade'
      # @kongregate.stats.submit 'GameComplete', @_count game.unit 'ascension'
      # @kongregate.stats.submit 'Mutations Unlocked', @_count game.upgrade 'mutatehidden'
      @kongregate.stats.submit 'Achievement Points', game.achievementPoints()
      @_submitTimetrialMins 'Minutes to First Racing Upgrade', game.upgrade 'driving_upgrade'
      @_submitTimetrialMins 'Minutes to First Sponsor', game.unit 'sponsor1'
      @_submitTimetrialMins 'Minutes to Racer', game.upgrade 'autoclicker_buy'
      @_submitTimetrialMins 'Minutes to End Game', game.upgrade 'car10_buy'
      @_submitTimetrialMins 'Minutes to Last Car', game.upgrade 'car26_buy'
      # @_submitTimetrialMins 'Minutes to First Ascension', game.unit 'ascension'
    catch e
      $log.warn 'kongregate reportstats failed - continuing', e

  _count: (u) ->
    return u.count().floor().toNumber()
  _timetrialMins: (u) ->
    if (millis = u.statistics()?.elapsedFirst)
      return Math.ceil millis / 1000 / 60
  _submitTimetrialMins: (name, u) ->
    time = @_timetrialMins u
    if time
      @kongregate.stats.submit name, time
  _countBought: (units) ->
    return _.reduce units, (sum, unit) ->
      if unit.count().isZero()
        sum
      else
        sum + 1
    , 0

angular.module('racingApp').factory 'kongregate', ($log, Kongregate) ->
  ret = new Kongregate()
  $log.debug 'isKongregate:', ret.isKongregate()
  if ret.isKongregate()
    ret.load()
  return ret
