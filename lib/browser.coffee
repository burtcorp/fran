module.exports = (wd, logger, sauce = {}) ->
  {username, apiKey} = sauce

  browser =
    if username && apiKey
      wd.remote('ondemand.saucelabs.com', 80, username, apiKey)
    else
      wd.remote()

  browser.on 'status', (info) ->
    logger.info(info)

  browser.on 'command', (eventType, command, response) ->
    output = eventType + ' ' + command
    output += ' ' + response if response
    logger.info(output)

  browser.on 'http', (method, path, data) ->
    output = method + ' ' + path
    output += ' ' + data if data
    logger.info(output)

  browser
