sinon = require('sinon')

Browser = require('../lib/browser')
Evented = require('../lib/evented')

describe 'Browser', ->
  def 'localBrowser', ->
    new Evented
  def 'sauceBrowser', ->
    new Evented
  def 'wd', ->
    stub = sinon.stub()
    stub.returns(@localBrowser)
    stub.withArgs('ondemand.saucelabs.com', 80, 'username', 'apiKey').returns(@sauceBrowser)
    remote: stub
  def 'logger', ->
    info: sinon.stub()
  def 'sauce', -> {}

  subject ->
    Browser(@wd, @logger, @sauce)

  it 'creates local browser by default', ->
    expect(@subject).to.eql(@localBrowser)

  it 'creates sauce browser if sauce credentials are specified', ->
    @sauce.username = 'username'
    @sauce.apiKey = 'apiKey'
    expect(@subject).to.eql(@sauceBrowser)

  describe 'logging', ->
    it 'logs status event', ->
      @subject.emit 'status', 'STATUS'
      expect(@logger.info.calledWithExactly('STATUS'))

    it 'logs command event', ->
      @subject.emit 'command', 'type', 'command', 'response'
      expect(@logger.info.calledWithExactly('type command response'))

    it 'logs command event when no response', ->
      @subject.emit 'command', 'type', 'command'
      expect(@logger.info.calledWithExactly('type command'))

    it 'logs http event', ->
      @subject.emit 'http', 'method', 'path', 'data'
      expect(@logger.info.calledWithExactly('method path data'))

    it 'logs http event when no data', ->
      @subject.emit 'http', 'method', 'path'
      expect(@logger.info.calledWithExactly('method path'))
