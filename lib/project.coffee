path = require('path')

Config = require('./config')

rootPath = process.cwd()
franPath = Config.franPath
viewsPath = path.join(franPath, 'views')
publicPath = path.join(franPath, 'public')
supportPath = path.join(franPath, 'support')
featuresPath = path.join(franPath, 'features')

Project = (name) ->
  rootPath = path.join(featuresPath, name)

  appPath: path.join(rootPath, 'app')
  viewsPath: path.join(rootPath, 'views')
  publicPath: path.join(rootPath, 'public')

Project.rootPath = rootPath
Project.franPath = franPath
Project.viewsPath = viewsPath
Project.publicPath = publicPath
Project.supportPath = supportPath
Project.featuresPath = featuresPath

module.exports = Project
