path = require('path')

module.exports = do ->
  ports =
    if franPorts = process.env['FRAN_PORT']
      franPorts.split(',').map(Number)
    else
      [8000, 8001]

  browserName = process.env['FRAN_BROWSER'] || 'firefox'

  franPath = path.join(process.cwd(), process.env['FRAN_PATH']) ||
             path.join(process.cwd(), 'test', 'fran')

  ports: ports
  franPath: franPath
  browserName: browserName
