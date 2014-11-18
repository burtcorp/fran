path = require('path')

module.exports = do ->
  rootPath = process.cwd()
  franPath = path.join(rootPath, 'test', 'fran')

  rootPath: rootPath
  franPath: franPath
  viewsPath: path.join(franPath, 'views')
  publicPath: path.join(franPath, 'public')
  supportPath: path.join(franPath, 'support')
  featuresPath: path.join(franPath, 'features')
