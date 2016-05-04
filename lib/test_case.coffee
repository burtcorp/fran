w = require('when')

Evented = require('./evented')

module.exports = (name, capabilities, ports, project, feature, token, app, browser, path) ->
  evented = Evented()

  isStarted = false

  app.get '/', (req, res) ->
    res.render 'index', name: name

  app: app

  feature: feature

  mount: (server) ->
    server.use '/' + token, app

  use: (name) ->
    module = require path.join(project.supportPath, name)
    module(@)

  start: ->
    w.promise (resolve, reject) ->
      if isStarted
        resolve()
      else
        browser.init capabilities, (err) ->
          if err
            reject(err.message)
          else
            browser.get 'http://localhost:' + ports[0] + '/' + token + '/', (err) ->
              if err
                reject(err.message)
              else
                isStarted = true

                resolve()

  stop: ->
    w.promise (resolve, reject) ->
      if isStarted
        browser.quit (err) ->
          if err
            reject(err.message)
          else
            isStarted = false

            resolve()
      else
        resolve()

  on: evented.on
  emit: evented.emit
