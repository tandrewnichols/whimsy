_ = require 'lodash'
sinon = require 'sinon'
path = require 'path'
chalk = require 'chalk'

describe 'cli', ->
  afterEach -> @fs.writeFile.restore()
  Given -> @lists =
    foo: ['a', 'b']
    bar:
      baz: ['quux']
  Given -> @words =
    get: => @lists
  Given -> @subject = proxyquire '../../lib/cli',
    '../lib/words': @words
  Given -> @fs = require 'fs'
  Given -> sinon.stub @fs, 'writeFile'
  Given -> @path = path.resolve __dirname, '../../lib/parts-of-speech.json'

  describe '.add', ->
    afterEach -> @subject.logBlock.restore()
    Given -> sinon.stub @subject, 'logBlock'
    Given -> @fs.writeFile.withArgs(@path, sinon.match.string, { encoding: 'utf8' }, sinon.match.func).callsArgWith 3, null, 'blah'

    context 'top level object', ->
      Given -> @lists.banana = ['foo']
      When -> @subject.add 'banana', 'bar', {}
      Then ->
        @lists.banana.should.eql ['foo', 'bar']
        @subject.logBlock.should.have.been.calledWith chalk.green(1), 'banana', 'added'

    context 'nested object', ->
      Given -> @lists.fruit =
        banana: ['foo']
      When -> @subject.add 'fruit.banana', 'bar', {}
      Then ->
        @lists.fruit.banana.should.eql ['foo', 'bar']
        @subject.logBlock.should.have.been.calledWith chalk.green(1), 'fruit.banana', 'added'

    context 'multiple words', ->
      Given -> @lists.banana = ['foo']
      When -> @subject.add 'banana', 'bar', 'baz', 'quux', {}
      Then ->
        @lists.banana.should.eql ['foo', 'bar', 'baz', 'quux']
        @subject.logBlock.should.have.been.calledWith chalk.green(3), 'banana', 'added'

    context 'duplicate words', ->
      Given -> @lists.banana = ['foo']
      When -> @subject.add 'banana', 'foo', {}
      Then ->
        @lists.banana.should.eql ['foo']
        @fs.writeFile.should.not.have.been.called()

  describe '.remove', ->

  describe '.logBlock', ->
    afterEach -> console.log.restore()
    Given -> sinon.stub console, 'log'
    When -> @subject.logBlock '2', 'banana', 'eaten'
    Then ->
      console.log.callCount.should.eql 3
      console.log.getCall(1).args.should.eql ['  ', '2', 'bananas', 'eaten']
