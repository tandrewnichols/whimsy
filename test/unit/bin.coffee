clear = require 'clear-require'
_ = require 'lodash'

describe 'bin/whimsy', ->
  afterEach -> process.argv = @_argv
  Given -> @_argv = process.argv
  Given -> clear '../../bin/whimsy'
  Given -> @whimsy = sinon.stub()
  Given -> @whimsy.noun = sinon.stub()
  Given -> @whimsy.verb = sinon.stub()
  Given -> @whimsy.adjective = sinon.stub()
  Given -> @whimsy.adverb = sinon.stub()
  Given -> @whimsy.pronoun = sinon.stub()
  Given -> @whimsy.preposition = sinon.stub()
  Given -> @whimsy.conjunction = sinon.stub()
  Given -> @whimsy.interjection = sinon.stub()
  Given -> @whimsy.article = sinon.stub()

  Given -> @cli =
    add: sinon.stub()
    remove: sinon.stub()
    writeResult: (fn) -> fn

  Given -> clear 'commander'

  context 'has the correct setup', ->
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
    Then ->
      @subject.version.should.eql '1.0.0'
      _.pluck(@subject.commands, '_name').should.eql [
        'add', 'remove', 'noun', 'verb', 'adjective', 'adverb', 'pronoun',
        'preposition', 'conjunction', 'interjection', 'article'
      ]
      _.pluck(@subject.commands, '_args').should.eql [
        [
          required: true
          name: 'type'
          variadic: false
        ,
          required: true
          name: 'words'
          variadic: true
        ],
        [
          required: true
          name: 'type'
          variadic: false
        ,
          required: true
          name: 'words'
          variadic: true
        ]
        [],
        [],
        [],
        [],
        [
          required: false
          name: 'type'
          variadic: false
        ],
        [],
        [
          required: false
          name: 'type'
          variadic: false
        ],
        [],
        []
      ]
      _.pluck(@subject.commands, '_description').should.eql [
        'Add a new word to the list of words',
        'Remove a word from the list of words',
        'Generate a noun',
        'Generate a verb',
        'Generate an adjective',
        'Generate an adverb',
        'Generate a pronoun',
        'Generate a preposition',
        'Generate a conjunction',
        'Generate an interjection',
        'Generate an article'
      ]
      _.pluck(@subject.commands, '_alias')[1].should.eql 'rm'
      _(@subject.commands).pluck('options').flatten().pluck('flags').value().should.eql [
        '-c, --count [count]',
        '-f, --filter [filter]',
        '-c, --count [count]',
        '-f, --filter [filter]',
        '-c, --count [count]',
        '-f, --filter [filter]',
        '-c, --count [count]',
        '-f, --filter [filter]',
        '-c, --count [count]',
        '-f, --filter [filter]',
        '-c, --count [count]',
        '-f, --filter [filter]',
        '-c, --count [count]',
        '-f, --filter [filter]',
        '-c, --count [count]',
        '-f, --filter [filter]',
        '-c, --count [count]'
        '-f, --filter [filter]',
      ]

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

  describe '.verb', ->
    Given -> process.argv = ['node', 'whimsy', 'verb']
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
      '../lib/whimsy': @whimsy
    Then -> @whimsy.verb.calledWith(sinon.match.object).should.be.true

  describe '.adjective', ->
    Given -> process.argv = ['node', 'whimsy', 'adjective']
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
      '../lib/whimsy': @whimsy
    Then -> @whimsy.adjective.calledWith(sinon.match.object).should.be.true

  describe '.adverb', ->
    Given -> process.argv = ['node', 'whimsy', 'adverb']
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
      '../lib/whimsy': @whimsy
    Then -> @whimsy.adverb.calledWith(sinon.match.object).should.be.true

  describe '.pronoun', ->
    Given -> process.argv = ['node', 'whimsy', 'pronoun']
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
      '../lib/whimsy': @whimsy
    Then -> @whimsy.pronoun.calledWith(sinon.match.object).should.be.true

  describe '.preposition', ->
    Given -> process.argv = ['node', 'whimsy', 'preposition']
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
      '../lib/whimsy': @whimsy
    Then -> @whimsy.preposition.calledWith(sinon.match.object).should.be.true

  describe '.conjunction', ->
    Given -> process.argv = ['node', 'whimsy', 'conjunction']
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
      '../lib/whimsy': @whimsy
    Then -> @whimsy.conjunction.calledWith(sinon.match.object).should.be.true

  describe '.interjection', ->
    Given -> process.argv = ['node', 'whimsy', 'interjection']
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
      '../lib/whimsy': @whimsy
    Then -> @whimsy.interjection.calledWith(sinon.match.object).should.be.true

  describe '.article', ->
    Given -> process.argv = ['node', 'whimsy', 'article']
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
      '../lib/whimsy': @whimsy
    Then -> @whimsy.article.calledWith(sinon.match.object).should.be.true

  describe 'other random input', ->
    Given -> process.argv = ['node', 'whimsy.js', 'foo bar']
    When -> @subject = proxyquire '../../bin/whimsy',
      '../lib/cli': @cli
      '../lib/whimsy': @whimsy
    Then -> @whimsy.calledWith('foo bar', {}).should.be.true
    
