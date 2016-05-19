Server = require('./server')
Project = require('./project')
Token = require('./token')
TestCase = require('./test_case')
Feature = require('./feature')
Browser = require('./browser')
{Logger, NullLogger} = require('./logger')

wd = require('wd')
path = require('path')
express = require('express')
morgan = require('morgan')

module.exports = (options = {}) ->
  logger =
    if options.verbose
      Logger()
    else
      NullLogger()

  project: ->
    Project(options.rootPath, options.franPath, path)

  createServerApp: ->
    app = express()
    app.use express.static(@project().publicPath)
    app.use(morgan('combined')) if options.verbose
    app

  createTestCaseApp: (name) ->
    feature = @createFeature(name)
    app = express()
    app.use express.static(feature.publicPath)
    app.set('views', feature.viewsPath)
    app.locals.basedir = @project().viewsPath
    app.use(morgan('combined')) if options.verbose
    app

  createFeature: (name) ->
    Feature(name, @project(), path)

  createToken: ->
    Token.generate()

  createBrowser: ->
    Browser(wd, logger, options.sauce)

  createTestCase: ->
    (name) =>
      TestCase(name, options.capabilities, options.ports, @project(), @createFeature(name), @createToken(), @createTestCaseApp(name), @createBrowser(), path)

  createServer: ->
    Server(options.ports, @createTestCase(), @createServerApp(), process)
