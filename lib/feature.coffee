module.exports = (name, project, path) ->
  rootPath = path.join(project.featuresPath, name)

  appPath: path.join(rootPath, 'app')
  viewsPath: path.join(rootPath, 'views')
  publicPath: path.join(rootPath, 'public')
