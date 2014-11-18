require('jade')

w = require('when')
express = require('express')

Config = require('./config')
Project = require('./project')
TestCase = require('./test_case')

module.exports = () ->
  app = express()

  modules = []
  servers = []

  start: ->
    app.use express.static(Project.publicPath)

    app.set('views', Project.viewsPath)
    app.set('view engine', 'jade')

    w.all Config.ports.map (port) ->
      w.promise (resolve, reject) ->
        servers.push app.listen(port, resolve)

  use: (module) ->
    modules.push(module)

  stop: ->
    w.all servers.map (server) ->
      w.promise (resolve, reject) ->
        server.close(resolve)

  load: (name) ->
    testCase = TestCase(name)
    testCase.mount(app)

    modules.forEach (module) ->
      testCase.use(module)

    testCase
