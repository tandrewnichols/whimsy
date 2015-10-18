clear = require 'clear-require'

describe 'bin/whimsy', ->
  Given -> clear '../../bin/whimsy'
  Given -> @cli = require '../../lib/cli'
  Given -> @subject = require '../../bin/whimsy'

  describe '.add', ->
    afterEach -> @cli.add.restore()
    Given -> sinon.stub @cli, 'add'
    When -> @subject.parse ['node', 'whimsy', 'add', 'noun', 'foo']
    Then -> @cli.add.calledWith('noun', ['foo'], sinon.match.object).should.be.true

  describe '.remove', ->
    afterEach -> @cli.remove.restore()
    Given -> sinon.stub @cli, 'remove'
    When -> @subject.parse ['node', 'whimsy', 'remove', 'noun', 'foo']
    Then -> @cli.remove.calledWith('noun', ['foo'], sinon.match.object).should.be.true
