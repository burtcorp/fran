EventEmitter = require('events').EventEmitter

module.exports = ->
  history = {}

  eventEmitter = new EventEmitter

  on: (event, callback) ->
    (history[event] || []).forEach (args) ->
      callback(args...)

    eventEmitter.on(event, callback)

  emit: (event, args...) ->
    history[event] ?= []
    history[event].push(args)

    eventEmitter.emit(event, args...)
