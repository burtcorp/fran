Server = require('./server')
Project = require('./project')
Token = require('./token')
TestCase = require('./test_case')
Feature = require('./feature')

wd = require('wd')
path = require('path')
express = require('express')

module.exports = (options = {}) ->
  project: ->
    Project(options.rootPath, options.franPath, path)

  createServerApp: ->
    app = express()
    app.use express.static(@project().publicPath)
    app

  createTestCaseApp: (name) ->
    feature = @createFeature(name)
    app = express()
    app.use express.static(feature.publicPath)
    app.set('views', feature.viewsPath)
    app.locals.basedir = @project().viewsPath
    app

  createFeature: (name) ->
    Feature(name, @project(), path)

  createToken: ->
    Token.generate()

  createBrowser: ->
    {username, apiKey} = options.sauce

    if username && apiKey
      wd.remote('ondemand.saucelabs.com', 80, username, apiKey)
    else
      wd.remote()

  createTestCase: ->
    (name) =>
      TestCase(name, options.capabilities, options.ports, @project(), @createFeature(name), @createToken(), @createTestCaseApp(name), @createBrowser(), path)

  createServer: ->
    Server(options.ports, @createTestCase(), @createServerApp(), process)
