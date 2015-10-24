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
        @output += data.toString()
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
      When (done) -> @capture(['noun'], done)
      And -> @nouns = @reduce 'noun'
      Then -> @output.should.be.oneOf @nouns

    describe '.verb', ->
      When (done) -> @capture(['verb'], done)
      And -> @verbs = require('../../lib/parts-of-speech').verb.split(reg)
      Then -> @output.should.be.oneOf @verbs

    describe '.adjective', ->
      When (done) -> @capture(['adjective'], done)
      And -> @adjectives = @reduce 'adjective'
      Then -> @output.should.be.oneOf @adjectives

    describe '.adverb', ->
      When (done) -> @capture(['adverb'], done)
      And -> @adverbs = @reduce 'adverb'
      Then -> @output.should.be.oneOf @adverbs

    describe '.pronoun', ->
      context 'with no subtype', ->
        When (done) -> @capture(['pronoun'], done)
        And -> @pronouns = @reduce 'pronoun'
        Then -> @output.should.be.oneOf @pronouns

      context 'with a subtype', ->
        When (done) -> @capture(['pronoun', 'personal'], done)
        And -> @pronouns = @reduce 'pronoun', 'personal'
        Then -> @output.should.be.oneOf @pronouns

    describe '.preposition', ->
      When (done) -> @capture(['preposition'], done)
      And -> @prepositions = @reduce 'preposition'
      Then -> @output.should.be.oneOf @prepositions

    describe '.conjunction', ->
      context 'with no subtype', ->
        When (done) -> @capture(['conjunction'], done)
        And -> @conjunctions = @reduce 'conjunction'
        Then -> @output.should.be.oneOf @conjunctions

      context 'with a subtype', ->
        When (done) -> @capture(['conjunction', 'correlative'], done)
        And -> @conjunctions = @reduce 'conjunction', 'correlative'
        Then -> @output.should.be.oneOf @conjunctions

    describe '.interjection', ->
      When (done) -> @capture(['interjection'], done)
      And -> @interjections = @reduce 'interjection'
      Then -> @output.should.be.oneOf @interjections

    describe '.article', ->
      When (done) -> @capture(['article'], done)
      And -> @articles = @reduce 'article'
      Then -> @output.should.be.oneOf @articles
