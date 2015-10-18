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
    Given -> clear '../../lib/parts-of-speech'
    When (done) -> @spawn(whimsy, ['remove', 'noun', 'fire']).on 'close', -> done()
    And -> @nouns = require('../../lib/parts-of-speech').noun.split(reg)
    Then -> 'fire'.should.not.be.oneOf(@nouns)
