Token = require('../lib/token')

describe 'Token', ->
  describe '#generate', ->
    it 'generates random token', ->
      expect(Token.generate()).to.match(/[a-z0-9]+/)
