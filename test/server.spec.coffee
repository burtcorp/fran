w = require('when')

Server = require('../lib/server')

EventEmitter = require('events').EventEmitter

MockTestCase = ->
  (name) ->
    testCase = new EventEmitter
    testCase.modules = []
    testCase.use = (module) -> testCase.modules.push(module)
    testCase.mount = (app) -> testCase.app = app
    testCase.stop = (callback) ->
      w.promise (resolve, reject) ->
        testCase.emit 'stop', resolve, reject

    testCase.name = name
    testCase

MockServer = (port) ->
  server = new EventEmitter
  server.port = port
  server.close = (callback) -> server.emit 'close', callback
  server

MockApp = ->
  app = new EventEmitter
  app.servers = []
  app.listen = (port, callback) ->
    app.emit 'listen', port, callback

    MockServer(port)
  app

describe 'Server', ->
  def 'ports', ->
    [1, 2]

  def 'TestCase', ->
    MockTestCase()

  def 'app', ->
    MockApp()

  def 'process', ->
    process = new EventEmitter
    process.exit = (code) -> process.emit 'exit', code
    process

  def 'server', ->
    Server(@ports, @TestCase, @app, @process)

  def 'start', ->
    @app.on 'listen', (port, callback) ->
      callback()
    @server.start()

  it 'stops and exits on SIGINT signal', (done) ->
    @ports = []

    stopped = false
    exited = false

    checkDone = ->
      done() if stopped && exited

    @server.on 'stop', ->
      stopped = true
      checkDone()

    @process.on 'exit', (code) ->
      exited = true
      expect(code).to.equal(0)
      checkDone()

    @start.then =>
      @process.emit 'SIGINT'

  describe '#start', ->
    it 'starts one server per port', ->
      ports = []
      @app.on 'listen', (port) ->
        ports.push(port)
      @server.start()
      expect(ports).to.eql([1, 2])

    it 'returns promise that is resolved when all servers are started', (done) ->
      @app.on 'listen', (port, callback) ->
        callback()
      @server.start().then -> done()

    it 'returns promise that is not resolved unless server is started', (done) ->
      callbacks = []
      @app.on 'listen', (port, callback) ->
        callbacks.push(callback)
      @server.start().then ->
        done('promise should not be resolved, but was')
      callbacks[0]()
      done()

    it 'emits start event', (done) ->
      @server.on 'start', done
      @start

    it 'is resolved when already started', (done) ->
      @start.then =>
        @server.start().then -> done()

  describe '#stop', ->
    context 'started', ->
      beforeEach ->
        @start

      it 'closes down all servers', (done) ->
        server1Closed = false
        server2Closed = false
        @server.servers.forEach (server) ->
          server.on 'close', ->
            switch server.port
              when 1 then server1Closed = true
              when 2 then server2Closed = true
            done() if server1Closed && server2Closed
        @server.stop()

      it 'stops all test cases', (done) ->
        testCase1Stopped = false
        testCase2Stopped = false
        @server.load('foo')
        @server.load('bar')
        @server.testCases.forEach (testCase) ->
          testCase.on 'stop', ->
            switch testCase.name
              when 'foo' then testCase1Stopped = true
              when 'bar' then testCase2Stopped = true
            done() if testCase1Stopped && testCase2Stopped
        @server.stop()

      it 'returns promise that is resolved when all servers are closed and test cases stopped', (done) ->
        @server.load('foo')
        @server.load('bar')
        @server.servers.forEach (server) ->
          server.on 'close', (callback) -> callback()
        @server.testCases.forEach (testCase) ->
          testCase.on 'stop', (callback) -> callback()
        @server.stop().then -> done()

      it 'emits stop event', (done) ->
        @server.servers.forEach (server) ->
          server.on 'close', (callback) -> callback()
        @server.on 'stop', done
        @server.stop()

    it 'is resolved when not started', (done) ->
      @server.stop().then -> done()

  describe '#load', ->
    context 'started', ->
      beforeEach ->
        @start

      it 'pushes test case to list of test cases', ->
        @server.load('foo')
        @server.load('bar')
        [testCase1, testCase2] = @server.testCases
        expect(testCase1.name).to.equal('foo')
        expect(testCase2.name).to.equal('bar')

      it 'mounts test case on app', ->
        @server.load('foo')
        @server.load('bar')
        [testCase1, testCase2] = @server.testCases
        expect(testCase1.app).to.equal(@app)
        expect(testCase2.app).to.equal(@app)

      it 'uses all modules', ->
        @server.use('module1')
        @server.use('module2')
        @server.load('foo')
        @server.load('bar')
        [testCase1, testCase2] = @server.testCases
        expect(testCase1.modules).to.include('module1')
        expect(testCase1.modules).to.include('module2')
        expect(testCase2.modules).to.include('module1')
        expect(testCase2.modules).to.include('module2')

      it 'returns test case', ->
        actual = @server.load('bar')
        expected = @server.testCases[0]
        expect(expected).to.equal(actual)

    it 'throws error if not started', ->
      (=>
        @server.load('foo')
      ).should.throw(/not started/)

  describe '#isStarted', ->
    it 'is true when started and false when stopped', (done) ->
      @ports = []

      expect(@server.isStarted()).to.be.false
      @server.start().then =>
        expect(@server.isStarted()).to.be.true
        @server.stop().then =>
          expect(@server.isStarted()).to.be.false
          done()
