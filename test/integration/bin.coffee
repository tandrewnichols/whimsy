clear = require 'clear-require'
_ = require 'lodash'

describe.skip 'whimsy as a command line binary', ->
  Given -> @spawn = require('child_process').spawn

  describe '.add', ->
    context 'single word', ->
      Given -> clear '../../lib/parts-of-speech'
      When (done) -> @spawn('whimsy', ['add', 'noun', 'blerg']).on 'close', -> done()
      And -> @nouns = require('../../lib/parts-of-speech').noun
      Then -> _.contains(@nouns, 'blerg').should.be.true

    context 'multiple words', ->
      Given -> clear '../../lib/parts-of-speech'
      When (done) -> @spawn('whimsy', ['add', 'noun', 'blerg', 'foo']).on 'close', -> done()
      And -> @nouns = require('../../lib/parts-of-speech').noun
      Then ->
        _.contains(@nouns, 'blerg').should.be.true
        _.contains(@nouns, 'foo').should.be.true

    context 'does not add duplicate words', ->
      Given -> clear '../../lib/parts-of-speech'
      When (done) -> @spawn('whimsy', ['add', 'noun', 'fire']).on 'close', -> done()
      And -> @nouns = require('../../lib/parts-of-speech').noun
      Then -> _.filter(@nouns, (noun) -> noun == 'fire').length.should.eql 1

  describe '.remove', ->
    Given -> clear '../../lib/parts-of-speech'
    When (done) -> @spawn('whimsy', ['remove', 'noun', 'blerg']).on 'close', -> done()
    And -> @nouns = require('../../lib/parts-of-speech').noun
    Then -> _.contains(@nouns, 'blerg').should.be.false
