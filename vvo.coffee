module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  M = env.matcher

  mock = '{"Name":"Merianplatz","Status":{"Code":"Ok"},"Place":"Dresden","ExpirationTime":"\/Date(1510265515463+0100)\/","Departures":[{"Id":"70729498","LineName":"7","Direction":"Pennrich","Platform":{"Name":"2","Type":"Platform"},"Mot":"Tram","RealTime":"\/Date(1510266000000+0100)\/","ScheduledTime":"\/Date(1510266000000+0100)\/","State":"InTime","RouteChanges":[],"Diva":{"Number":"11007","Network":"voe"}},{"Id":"70731143","LineName":"44","Direction":"Gorbitz","Platform":{"Name":"2","Type":"Platform"},"Mot":"Tram","RealTime":"\/Date(1510266010000+0100)\/","ScheduledTime":"\/Date(1510265940000+0100)\/","State":"Delayed","RouteChanges":["510972","511363"],"Diva":{"Number":"11044","Network":"voe"}},{"Id":"70728574","LineName":"2","Direction":"Kleinzschachwitz","Platform":{"Name":"1","Type":"Platform"},"Mot":"Tram","RealTime":"\/Date(1510266300000+0100)\/","ScheduledTime":"\/Date(1510266300000+0100)\/","State":"InTime","RouteChanges":["511363"],"Diva":{"Number":"11002","Network":"voe"}},{"Id":"70728464","LineName":"2","Direction":"Gorbitz","Platform":{"Name":"2","Type":"Platform"},"Mot":"Tram","RealTime":"\/Date(1510266660000+0100)\/","ScheduledTime":"\/Date(1510266660000+0100)\/","State":"InTime","RouteChanges":["511363"],"Diva":{"Number":"11002","Network":"voe"}},{"Id":"70729626","LineName":"7","Direction":"Weixdorf","Platform":{"Name":"1","Type":"Platform"},"Mot":"Tram","RealTime":"\/Date(1510267260000+0100)\/","ScheduledTime":"\/Date(1510267260000+0100)\/","State":"InTime","RouteChanges":[],"Diva":{"Number":"11007","Network":"voe"}},{"Id":"70730165","LineName":"10","Direction":"Gorbitz","Platform":{"Name":"2","Type":"Platform"},"Mot":"Tram","RealTime":"\/Date(1510267336000+0100)\/","ScheduledTime":"\/Date(1510267260000+0100)\/","State":"Delayed","RouteChanges":["510972","511363"],"Diva":{"Number":"11010","Network":"voe"}}]}'
  test = "<div>HALLO WELT</div>"

  class VvoPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>
      env.logger.info(mock)

      @framework.ruleManager.addActionProvider(new VvoActionProvider(@framework))
      #@framework.ruleManager.addPredicateProvider(new VvoPredicateProvider(@framework))

      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("VvoDevice", {
        configDef: deviceConfigDef.VvoDevice,
        createCallback: (config) => new VvoDevice(config)
      })

      @framework.on "after init", =>
        mobileFrontend = @framework.pluginManager.getPlugin 'mobile-frontend'
        if mobileFrontend?
          mobileFrontend.registerAssetFile 'js', "pimatic-vvo/app/vvoTempl-page.coffee"
          mobileFrontend.registerAssetFile 'html', "pimatic-vvo/app/vvoTempl-template.html"
          mobileFrontend.registerAssetFile 'css', "pimatic-vvo/app/vvo.css"

        return

  class VvoDevice extends env.devices.Device
    attributes:
      stopid:
        description: "the stopid"
        type: "string"
        unit: ''
    template: 'vvo'

    constructor: (@config) ->
      @id = @config.id
      @name = @config.name
      @stopid = @config.stopid
      super()


    getStopid: -> Promise.resolve(@stopids)

    actions:
      loadSchedule:
        description: "turns the switch on"

    destroy: ->
      super()


  ####### ACTION HANDLER ######
  class VvoActionHandler extends env.actions.ActionHandler
    constructor: (@framework) ->

    loadSchedule: ->
      env.logger.info "Melde gehorsamst: Ausführung!"

    executeAction: (simulate) =>
      if simulate
        env.logger.info "Das ist nur eine Übung"
        return Promise.resolve(__("would log 42"))
      else
        @loadSchedule()
        return Promise.resolve(__("Auftrag ausgeführt"))




  ####### ACTION PROVIDER #######
  class VvoActionProvider extends env.actions.ActionProvider
    constructor: (@framework)->
      env.logger.info "VvoActionProvider meldet sich zum Dienst"
      return
    executeAction: (simulate) =>
      env.logger.info "VvoActionProvider meldet gehorsamst: Ausführung!"
      return
    parseAction: (input, context) =>
      match = null

      m = M(input, context)
        .match('doit')

      if m.hadMatch()
        match = m.getFullMatch()
        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new VvoActionHandler(@framework)
        }




  vvoPlugin = new VvoPlugin
  return vvoPlugin