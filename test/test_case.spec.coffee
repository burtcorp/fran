Evented = require('../lib/evented')
TestCase = require('../lib/test_case')

describe 'TestCase', ->
  def 'name', -> 'name'

  def 'capabilities', ->
    browserName: 'firefox'

  def 'ports', ->
    [1, 2]

  def 'project', ->

  def 'feature', ->

  def 'token', -> 'TOKEN'

  def 'app', ->
    app = Evented()
    app.get = (path, callback) -> app.emit 'get', path, callback
    app

  def 'browser', ->
    browser = Evented()
    browser.get = (url, callback) -> browser.emit 'get', url, callback
    browser.init = (capabilities, callback) -> browser.emit 'init', capabilities, callback
    browser.quit = (callback) -> browser.emit 'quit', callback
    browser

  def 'path', ->

  def 'start', ->
    @browser.on 'init', (config, callback) -> callback()
    @browser.on 'get', (url, callback) -> callback()
    @testCase.start()

  def 'testCase', ->
    TestCase(@name, @capabilities, @ports, @project, @feature, @token, @app, @browser, @path)

  it 'renders index on GET /', (done) ->
    @app.on 'get', (path, callback) ->
      callback {},
        render: (view, options) ->
          expect(view).to.equal('index')
          expect(options).to.eql(name: 'name')
          done()
    @testCase

  describe '#app', ->
    it 'is added to the API', ->
      expect(@testCase.app).to.equal(@app)

  describe '#feature', ->
    it 'is added to the API', ->
      expect(@testCase.feature).to.equal(@feature)

  describe '#mount', ->
    it 'mounts app on server on token namespace', (done) ->
      @testCase.mount
        use: (path, app) =>
          expect(path).to.equal('/TOKEN')
          expect(app).to.equal(@app)
          done()

  describe '#use', ->

  describe '#start', ->
    it 'initializes browser with browser name', (done) ->
      @browser.on 'init', (capabilities, callback) ->
        expect(capabilities.browserName).to.equal('firefox')
        done()
      @testCase.start()

    it 'retrieves url', (done) ->
      @browser.on 'init', (capabilities, callback) -> callback()
      @browser.on 'get', (url) ->
        expect(url).to.equal('http://localhost:1/TOKEN')
        done()
      @testCase.start()

    it 'returns promise that is resolved if browser successfully initialized and url was retrieved', (done) ->
      @browser.on 'init', (capabilities, callback) -> callback()
      @browser.on 'get', (url, callback) -> callback()
      @testCase.start().then -> done()

    it 'rejects promise if browser was not successfully initialized', (done) ->
      @browser.on 'init', (capabilities, callback) -> callback(message: 'reason')
      resolve = ->
      reject = (reason) ->
        expect(reason).to.equal('reason')
        done()
      @testCase.start().then(resolve, reject)

    it 'rejects promise if url was not retrieved', (done) ->
      @browser.on 'init', (capabilities, callback) -> callback()
      @browser.on 'get', (url, callback) -> callback(message: 'reason')
      resolve = ->
      reject = (reason) ->
        expect(reason).to.equal('reason')
        done()
      @testCase.start().then(resolve, reject)

    it 'is resolved when already started', (done) ->
      @start.then =>
        @testCase.start().then -> done()

  describe '#stop', ->
    context 'started', ->
      beforeEach ->
        @start

      it 'quits browser', (done) ->
        @browser.on 'quit', -> done()
        @testCase.stop()

      it 'returns promise that is resolved if browser quit successfully', (done) ->
        @browser.on 'quit', (callback) -> callback()
        @testCase.stop().then -> done()

      it 'rejects promise if browser was not quit successfully', (done) ->
        @browser.on 'quit', (callback) -> callback(message: 'reason')
        resolve = ->
        reject = (reason) ->
          expect(reason).to.equal('reason')
          done()
        @testCase.stop().then(resolve, reject)

    it 'is resolved when not started', (done) ->
      @testCase.stop().then -> done()

  describe '#on/#emit', ->
    it 'is added to the API', (done) ->
      @testCase.on 'event', done
      @testCase.emit 'event'
