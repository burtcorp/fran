w = require('when')

Evented = require('./evented')

module.exports = (ports, TestCase, app, process) ->
  evented = Evented()

  modules = []
  servers = []
  testCases = []

  isStarted = false

  process.on 'SIGINT', ->
    stop().then -> process.exit(0)

  evented.on 'start', ->
    isStarted = true

  evented.on 'stop', ->
    isStarted = false

  start = ->
    if isStarted
      w.promise (resolve) -> resolve()
    else
      promise = w.all ports.map (port) ->
        w.promise (resolve, reject) ->
          servers.push app.listen(port, resolve)

      promise.then ->
        evented.emit 'start'

      promise

  stop = ->
    if isStarted
      promises = []

      servers.forEach (server) ->
        promises.push w.promise (resolve, reject) ->
          server.close(resolve)

      testCases.forEach (testCase) ->
        promises.push testCase.stop()

      promise = w.all(promises)
      promise.then -> evented.emit 'stop'
      promise
    else
      w.promise (resolve) -> resolve()

  use = (module) ->
    modules.push(module)

  load = (name) ->
    unless isStarted
      throw new Error('Cannot load, server is not started')

    testCase = TestCase(name)
    testCase.mount(app)
    testCases.push(testCase)

    modules.forEach (module) ->
      testCase.use(module)

    testCase

  on: evented.on
  isStarted: -> isStarted
  modules: modules
  servers: servers
  testCases: testCases
  start: start
  stop: stop
  use: use
  load: load
