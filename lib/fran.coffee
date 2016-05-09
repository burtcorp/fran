path = require('path')

Factory = require('./factory')

module.exports = (options = {}) ->
  if process.env['FRAN_SAUCE'] == '0'
    options.sauce = false
  else
    options.sauce =
      username: process.env['SAUCE_USERNAME']
      apiKey: process.env['SAUCE_API_KEY']

  options.ports =
    if franPorts = process.env['FRAN_PORT']
      franPorts.split(',').map(Number)
    else
      [8000, 8001]

  options.capabilities =
    browserName: process.env['SAUCE_BROWSER'] || process.env['FRAN_BROWSER'] || 'chrome'
    platform: process.env['SAUCE_PLATFORM']
    version: process.env['SAUCE_VERSION']

  options.rootPath = process.cwd()

  options.franPath = path.join(process.cwd(), process.env['FRAN_PATH']) ||
                     path.join(process.cwd(), 'test', 'fran')

  options.verbose = process.env['FRAN_VERBOSE']

  factory = Factory(options)
  factory.createServer()
