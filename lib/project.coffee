module.exports = (rootPath, franPath, path) ->
  viewsPath = path.join(franPath, 'views')
  publicPath = path.join(franPath, 'public')
  supportPath = path.join(franPath, 'support')
  featuresPath = path.join(franPath, 'features')

  rootPath: rootPath
  franPath: franPath
  viewsPath: viewsPath
  publicPath: publicPath
  supportPath: supportPath
  featuresPath: featuresPath
