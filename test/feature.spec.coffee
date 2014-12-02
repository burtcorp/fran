Feature = require('../lib/feature')

describe 'Feature', ->
  def 'name', -> 'name'

  def 'project', ->
    featuresPath: 'path/to/features'

  def 'path', -> require('path')

  def 'feature', -> Feature(@name, @project, @path)

  describe '#appPath', ->
    it 'returns path to app directory', ->
      expect(@feature.appPath).to.equal('path/to/features/name/app')

  describe '#viewsPath', ->
    it 'returns path to views directory', ->
      expect(@feature.viewsPath).to.equal('path/to/features/name/views')

  describe '#publicPath', ->
    it 'returns path to public directory', ->
      expect(@feature.publicPath).to.equal('path/to/features/name/public')
