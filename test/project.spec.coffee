Project = require('../lib/project')

describe 'Project', ->
  def 'rootPath', -> 'root/path'

  def 'franPath', -> 'fran/path'

  def 'path', -> require('path')

  def 'project', -> Project(@rootPath, @franPath, @path)

  describe '#rootPath', ->
    it 'returns root path', ->
      expect(@project.rootPath).to.equal('root/path')

  describe '#franPath', ->
    it 'returns fran path', ->
      expect(@project.franPath).to.equal('fran/path')

  describe '#viewsPath', ->
    it 'return views path', ->
      expect(@project.viewsPath).to.equal('fran/path/views')

  describe '#publicPath', ->
    it 'returns public path', ->
      expect(@project.publicPath).to.equal('fran/path/public')

  describe '#supportPath', ->
    it 'returns support path', ->
      expect(@project.supportPath).to.equal('fran/path/support')

  describe '#featuresPath', ->
    it 'retusn features path', ->
      expect(@project.featuresPath).to.equal('fran/path/features')
