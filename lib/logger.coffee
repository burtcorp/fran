module.exports =
  Logger: ->
    info: (message) ->
      console.log 'INFO:', message
  NullLogger: ->
    info: ->
