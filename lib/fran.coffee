w = require('when')
express = require('express')

Config = require('./config')
Project = require('./project')
TestCase = require('./test_case')

module.exports = ->
  app = express()

  modules = []
  servers = []
  testCases = []

  stop = ->
    promises = []

    servers.forEach (server) ->
      promises.push w.promise (resolve, reject) ->
        server.close(resolve)

    testCases.forEach (testCase) ->
      promises.push w.promise (resolve, reject) ->
        testCase.stop().then(resolve)

    w.all(promises)

  start: ->
    app.use express.static(Project.publicPath)

    process.on 'SIGINT', ->
      stop().then(process.exit)

    w.all Config.ports.map (port) ->
      w.promise (resolve, reject) ->
        servers.push app.listen(port, resolve)

  use: (module) ->
    modules.push(module)

  stop: stop

  load: (name) ->
    testCase = TestCase(name)
    testCase.mount(app)
    testCases.push(testCase)

    modules.forEach (module) ->
      testCase.use(module)

    testCase
