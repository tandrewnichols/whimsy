clear = require 'clear-require'
_ = require 'lodash'
reg = /\s*,\s*/
path = require 'path'
whimsy = path.resolve __dirname, '../../bin/whimsy.js'

describe 'whimsy as a command line binary', ->
  Given -> @spawn = require('child_process').spawn
  afterEach (done) -> @spawn('git', ['checkout', 'lib/parts-of-speech.json']).on 'close', -> done()

  describe '.add', ->
    context 'single word', ->
      Given -> clear '../../lib/parts-of-speech'
      When (done) -> @spawn(whimsy, ['add', 'noun', 'blerg']).on 'close', -> done()
      And -> @nouns = require('../../lib/parts-of-speech').noun.split(reg)
      Then -> _.contains(@nouns, 'blerg').should.be.true

    context 'multiple words', ->
      Given -> clear '../../lib/parts-of-speech'
      When (done) -> @spawn(whimsy, ['add', 'noun', 'blerg', 'foo']).on 'close', -> done()
      And -> @nouns = require('../../lib/parts-of-speech').noun.split(reg)
      Then ->
        _.contains(@nouns, 'blerg').should.be.true
        _.contains(@nouns, 'foo').should.be.true

    context 'does not add duplicate words', ->
      Given -> clear '../../lib/parts-of-speech'
      When (done) -> @spawn(whimsy, ['add', 'noun', 'fire']).on 'close', -> done()
      And -> @nouns = require('../../lib/parts-of-speech').noun.split(reg)
      And -> @filter = (noun) -> noun == 'fire'
      Then -> _.filter(@nouns, @filter).length.should.eql 1

  describe '.remove', ->
    context 'single word', ->
      Given -> clear '../../lib/parts-of-speech'
      When (done) -> @spawn(whimsy, ['remove', 'noun', 'fire']).on 'close', -> done()
      And -> @nouns = require('../../lib/parts-of-speech').noun.split(reg)
      Then -> 'fire'.should.not.be.oneOf(@nouns)

    context 'multiple words', ->
      Given -> clear '../../lib/parts-of-speech'
      When (done) -> @spawn(whimsy, ['remove', 'noun', 'fire', 'sheet']).on 'close', -> done()
      And -> @nouns = require('../../lib/parts-of-speech').noun.split(reg)
      Then -> _.intersection(['fire', 'sheet'], @nouns).should.eql []

  context 'generating', ->
    Given -> clear '../../lib/parts-of-speech'
    Given -> @output = ''
    Given -> @capture = (args, done) =>
      child = @spawn(whimsy, args)
      child.stdout.on 'data', (data) =>
        @output += data.toString().replace('\n', '')
      child.on 'close', -> done()
    Given -> @reduce = (type, subtype) ->
      list = require('../../lib/parts-of-speech')[type]
      if (typeof list is 'string')
        return list.split(reg)
      else if (subtype)
        return list[subtype].split(reg)
      else
        return _.reduce list, (memo, val, key) ->
          return memo.concat val.split(reg)
        , []

    describe '.noun', ->
      context 'no options', ->
        When (done) -> @capture(['noun'], done)
        And -> @nouns = @reduce 'noun'
        Then -> @output.should.be.oneOf @nouns

      context 'with a count', ->
        When (done) -> @capture(['noun', '-c', 2], done)
        Then -> @output.split(reg).length.should.eql 2

      context 'with filters', ->
        When (done) -> @capture(['noun', '-f', 'capitalize', '--filter', 'startsWith("s")'], done)
        Then -> @output.should.match /^S/

    describe '.verb', ->
      context 'no options', ->
        When (done) -> @capture(['verb'], done)
        And -> @verbs = @reduce 'verb'
        Then -> @output.should.be.oneOf @verbs

      context 'with a count', ->
        When (done) -> @capture(['verb', '-c', 2], done)
        Then -> @output.split(reg).length.should.eql 2

      context 'with filters', ->
        When (done) -> @capture(['verb', '-f', 'capitalize', '--filter', 'startsWith("s")'], done)
        Then -> @output.should.match /^S/

    describe '.adjective', ->
      context 'no options', ->
        When (done) -> @capture(['adjective'], done)
        And -> @adjectives = @reduce 'adjective'
        Then -> @output.should.be.oneOf @adjectives

      context 'with a count', ->
        When (done) -> @capture(['adjective', '--count', 2], done)
        Then -> @output.split(reg).length.should.eql 2

      context 'with filters', ->
        When (done) -> @capture(['adjective', '-f', 'capitalize', '--filter', 'startsWith("s")'], done)
        Then -> @output.should.match /^S/

    describe '.adverb', ->
      context 'no options', ->
        When (done) -> @capture(['adverb'], done)
        And -> @adverbs = @reduce 'adverb'
        Then -> @output.should.be.oneOf @adverbs

      context 'with a count', ->
        When (done) -> @capture(['adverb', '-c', 2], done)
        Then -> @output.split(reg).length.should.eql 2

      context 'with filters', ->
        When (done) -> @capture(['adverb', '-f', 'capitalize', '--filter', 'startsWith("q")'], done)
        Then -> @output.should.match /^Q/

    describe '.pronoun', ->
      context 'with no subtype', ->
        context 'no options', ->
          When (done) -> @capture(['pronoun'], done)
          And -> @pronouns = @reduce 'pronoun'
          Then -> @output.should.be.oneOf @pronouns

        context 'with a count', ->
          When (done) -> @capture(['pronoun', '-c', 2], done)
          Then -> @output.split(reg).length.should.eql 2

      context 'with a subtype', ->
        context 'no options', ->
          When (done) -> @capture(['pronoun', 'personal'], done)
          And -> @pronouns = @reduce 'pronoun', 'personal'
          Then -> @output.should.be.oneOf @pronouns

        context 'with a count', ->
          When (done) -> @capture(['pronoun', 'personal', '-c', 2], done)
          Then -> @output.split(reg).length.should.eql 2

      context 'with filters', ->
        When (done) -> @capture(['pronoun', 'reflexive', '-f', 'capitalize', '--filter', 'startsWith("m")'], done)
        Then -> @output.should.eql 'Myself'

    describe '.preposition', ->
      context 'no options', ->
        When (done) -> @capture(['preposition'], done)
        And -> @prepositions = @reduce 'preposition'
        Then -> @output.should.be.oneOf @prepositions

      context 'with a count', ->
        When (done) -> @capture(['preposition', '-c', 2], done)
        Then -> @output.split(reg).length.should.eql 2

      context 'with filters', ->
        When (done) -> @capture(['preposition', '-f', 'capitalize', '--filter', 'startsWith("s")'], done)
        Then -> @output.should.match /^S/

    describe '.conjunction', ->
      context 'with no subtype', ->
        context 'no options', ->
          When (done) -> @capture(['conjunction'], done)
          And -> @conjunctions = @reduce 'conjunction'
          Then -> @output.should.be.oneOf @conjunctions

        context 'with a count', ->
          When (done) -> @capture(['conjunction', '-c', 2], done)
          Then -> @output.split(reg).length.should.eql 2

      context 'with a subtype', ->
        context 'no options', ->
          When (done) -> @capture(['conjunction', 'correlative'], done)
          And -> @conjunctions = @reduce 'conjunction', 'correlative'
          Then -> @output.should.be.oneOf @conjunctions

        context 'with a count', ->
          When (done) -> @capture(['conjunction', 'correlative', '-c', 2], done)
          Then -> @output.split(reg).length.should.eql 2

      context 'with filters', ->
        When (done) -> @capture(['conjunction', '-f', 'capitalize', '--filter', 'startsWith("s")'], done)
        Then -> @output.should.match /^S/

    describe '.interjection', ->
      context 'no options', ->
        When (done) -> @capture(['interjection'], done)
        And -> @interjections = @reduce 'interjection'
        Then -> @output.should.be.oneOf @interjections

      context 'with a count', ->
        When (done) -> @capture(['interjection', '-c', 2], done)
        Then -> @output.split(reg).length.should.eql 2

      context 'with filters', ->
        When (done) -> @capture(['interjection', '-f', 'capitalize', '--filter', 'startsWith("s")'], done)
        Then -> @output.should.match /^S/

    describe '.article', ->
      context 'no options', ->
        When (done) -> @capture(['article'], done)
        And -> @articles = @reduce 'article'
        Then -> @output.should.be.oneOf @articles

      context 'with a count', ->
        When (done) -> @capture(['article', '-c', 2], done)
        Then -> @output.split(reg).length.should.eql 2

      context 'with filters', ->
        When (done) -> @capture(['article', '-f', 'capitalize', '--filter', 'startsWith("a")'], done)
        Then -> @output.should.match /^A/

    describe 'with no specific command', ->
      context 'with interpolation', ->
        context 'no options', ->
          When (done) -> @capture(["The {{ noun }}"], done)
          And -> @nouns = @reduce 'noun'
          Then ->
            @output.should.match /The [a-z]+/
            @output.replace('The ', '').should.be.oneOf @nouns

        context 'with a count', ->
          When (done) -> @capture(["The {{ noun }}", '-c', 2], done)
          Then -> @output.split(reg).length.should.eql 2

      context 'with no interpolation', ->
        When (done) -> @capture(["blah"], done)
        Then -> @output.should.eql 'blah'
