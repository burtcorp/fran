module.exports = do ->
  ports =
    if franPorts = process.env['FRAN_PORT']
      franPorts.split(',').map(Number)
    else
      [8000, 8001]

  browserName = process.env['FRAN_BROWSER'] || 'firefox'

  ports: ports
  browserName: browserName
