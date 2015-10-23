clear = require 'clear-require'

describe 'bin/whimsy', ->
  afterEach -> process.argv = @_argv
  Given -> @_argv = process.argv
  Given -> clear '../../bin/whimsy'
  Given -> @whimsy =
    noun: sinon.stub()

  Given -> @cli =
    add: sinon.stub()
    remove: sinon.stub()
    writeResult: (fn) -> fn

  context 'has the correct version', ->
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
    Then -> @subject.version.should.eql '1.0.0'

  describe '.add', ->
    Given -> process.argv = ['node', 'whimsy', 'add', 'noun', 'foo']
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
    Then -> @cli.add.calledWith('noun', ['foo'], sinon.match.object).should.be.true

  describe '.remove', ->
    Given -> process.argv = ['node', 'whimsy', 'remove', 'noun', 'foo']
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
    Then -> @cli.remove.calledWith('noun', ['foo'], sinon.match.object).should.be.true

  describe '.noun', ->
    Given -> process.argv = ['node', 'whimsy', 'noun']
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
      '../lib/whimsy': @whimsy
    Then -> @whimsy.noun.calledWith(sinon.match.object).should.be.true
