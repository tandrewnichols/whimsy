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
  Given -> @whimsy =
    parse: sinon.stub()
  Given -> @block = sinon.stub()
  Given -> @subject = proxyquire '../../lib/cli',
    './words': @words
    './whimsy': @whimsy
    'log-block': @block
  Given -> @fs = require 'fs'
  Given -> sinon.stub @fs, 'writeFile'
  Given -> @path = path.resolve __dirname, '../../lib/parts-of-speech.json'

  describe '.add', ->
    Given -> @words.stringify = sinon.stub()
    Given -> @words.stringify.withArgs(@lists).returns 'many bananas'
    Given -> @fs.writeFile.withArgs(@path, 'many bananas', { encoding: 'utf8' }, sinon.match.func).callsArgWith 3, null, 'blah'

    context 'top level object', ->
      Given -> @lists.banana = ['foo']
      When -> @subject.add 'banana', ['bar'], {}
      Then ->
        @lists.banana.should.eql ['foo', 'bar']
        @block.should.have.been.calledWith chalk.green(1), 'banana', 'added'

    context 'nested object', ->
      Given -> @lists.fruit =
        banana: ['foo']
      When -> @subject.add 'fruit.banana', ['bar'], {}
      Then ->
        @lists.fruit.banana.should.eql ['foo', 'bar']
        @block.should.have.been.calledWith chalk.green(1), 'fruit', 'added'

    context 'multiple words', ->
      Given -> @lists.banana = ['foo']
      When -> @subject.add 'banana', ['bar', 'baz', 'quux'], {}
      Then ->
        @lists.banana.should.eql ['foo', 'bar', 'baz', 'quux']
        @block.should.have.been.calledWith chalk.green(3), 'bananas', 'added'

    context 'duplicate words', ->
      Given -> @lists.banana = ['foo']
      When -> @subject.add 'banana', ['foo'], {}
      Then ->
        @lists.banana.should.eql ['foo']
        @fs.writeFile.should.not.have.been.called()
        @block.should.have.been.calledWith chalk.red(0), 'bananas', 'added'

  describe '.remove', ->
    Given -> @words.stringify = sinon.stub()
    Given -> @words.stringify.withArgs(@lists).returns 'many bananas'
    Given -> @fs.writeFile.withArgs(@path, 'many bananas', { encoding: 'utf8' }, sinon.match.func).callsArgWith 3, null, 'blah'

    context 'top level object', ->
      Given -> @lists.banana = ['foo']
      When -> @subject.remove 'banana', ['foo'], {}
      Then ->
        @lists.banana.should.eql []
        @block.should.have.been.calledWith chalk.green(1), 'banana', 'removed'

  describe '.writeResult', ->
    afterEach -> console.log.restore()
    Given -> sinon.stub console, 'log'
    Given -> @foo = sinon.stub()
    Given -> @foo.returns 'bar'

    context 'with no arguments', ->
      When -> @func = @subject.writeResult @foo
      And -> @func()
      Then -> console.log.should.have.been.calledWith 'bar'

    context 'with arguments', ->
      When -> @func = @subject.writeResult @foo
      And -> @func 'blah', 7, { options: true }
      Then -> @foo.should.have.been.calledWith 'blah', 7, { count: undefined, filters: undefined }

    context 'with options', ->
      Given -> @foo.returns ['bar', 'baz']
      When -> @func = @subject.writeResult @foo
      And -> @func 'blah', 7, { count: 2 }
      Then ->
        @foo.should.have.been.calledWith 'blah', 7, { count: 2, filters: undefined }
        console.log.should.have.been.calledWith 'bar, baz'

    context 'with filters', ->
      When -> @func = @subject.writeResult @foo
      And -> @func 'blah', { filter: [ name: 'banana' ] }
      Then -> @foo.should.have.been.calledWith 'blah', { count: undefined, filters: [ name: 'banana' ] }

  describe '.collectFilters', ->
    Given -> @whimsy.parse.withArgs('foo("bar")').returns name: 'bar'

    context 'memo is already an array', ->
      Then -> @subject.collectFilters('foo("bar")', [name: 'quux']).should.eql [
        name: 'quux'
      ,
        name: 'bar'
      ]

    context 'memo is undefined', ->
      Then -> @subject.collectFilters('foo("bar")').should.eql [
        name: 'bar'
      ]
