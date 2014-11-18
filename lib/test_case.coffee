w = require('when')
wd = require('wd')
express = require('express')
path = require('path')

Config = require('./config')
Project = require('./project')
Token = require('./token')

EventEmitter = require('events').EventEmitter

module.exports = (name) ->
  eventEmitter = new EventEmitter

  history = {}

  publicPath = path.join(Project.featuresPath, name, 'public')

  app = express()
  app.use express.static(publicPath)
  app.get '/', (req, res) ->
    res.render publicPath + '/index'
  app.locals.basedir = Project.viewsPath

  browser = undefined

  token = Token.generate()

  app: app

  mount: (server) ->
    server.use '/' + token, app

  use: (name) ->
    module = require path.join(Project.supportPath, name)
    module(@)

  start: ->
    w.promise (resolve, reject) ->
      browser = wd.remote()
      browser.init browserName: Config.browserName, ->
        browser.get 'http://localhost:' + Config.ports[0] + '/' + token, resolve

  stop: ->
    w.promise (resolve, reject) ->
      browser.quit(resolve)

  on: (event, callback) ->
    (history[event] || []).forEach (args) ->
      callback(args...)

    eventEmitter.on(event, callback)

  emit: (event, args...) ->
    history[event] ?= []
    history[event].push(args)

    eventEmitter.emit(event, args...)
