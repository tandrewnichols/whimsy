sinon = require 'sinon'
_ = require 'lodash'

describe 'whimsy required as a module', ->
  Given -> @words = require '../../lib/parts-of-speech'
  Given -> @subject = require '../../lib/whimsy'

  describe '.noun', ->
    context 'no options', ->
      Then -> @subject.noun().should.be.oneOf @words.noun

  describe '.verb', ->
    context 'no options', ->
      Then -> @subject.verb().should.be.oneOf @words.verb
    
  describe '.adjective', ->
    context 'no options', ->
      Then -> @subject.adjective().should.be.oneOf @words.adjective
     
  describe '.adverb', ->
    context 'no options', ->
      Then -> @subject.adverb().should.be.oneOf @words.adverb
    
  describe '.pronoun', ->
    context 'top level', ->
      Then -> @subject.pronoun().should.be.oneOf _(@words.pronoun).values().flatten().value()

    context 'nested', ->
      Then -> @subject.pronoun('reflexive').should.be.oneOf @words.pronoun.reflexive
    
  describe '.preposition', ->
    context 'no options', ->
      Then -> @subject.preposition().should.be.oneOf @words.preposition
    
  describe '.conjunction', ->
    context 'top level', ->
      Then -> @subject.conjunction().should.be.oneOf _(@words.conjunction).values().flatten().value()

    context 'nested', ->
      Then -> @subject.conjunction('correlative').should.be.oneOf @words.conjunction.correlative
    
  describe '.interjection', ->
    context 'no options', ->
      Then -> @subject.interjection().should.be.oneOf @words.interjection
    
  describe '.article', ->
    context 'no options', ->
      Then -> @subject.article().should.be.oneOf @words.article
    
  describe 'called as a function', ->
    context 'no duplicates', ->
      Given -> @parts = @subject('{{ adjective }}-{{ noun }}').split '-'
      Then -> @parts[0].should.be.oneOf @words.adjective
      And -> @parts[1].should.be.oneOf @words.noun

    context 'with duplicates', ->
      Given -> @parts = @subject('{{ noun }}-{{ noun }}').split '-'
      Then -> @parts[0].should.be.oneOf @words.noun
      And -> @parts[1].should.be.oneOf @words.noun
      And -> @parts[0].should.not.eql @parts[1]

    context 'nested property', ->

    context 'with post filters', ->
      afterEach -> _.random.restore()
      Given -> sinon.stub(_, 'random').returns 0

      context 'pluralize', ->
        Then -> @subject('{{ noun | pluralize }}').should.eql 'fires'
      
      context 'capitalize', ->
        Then -> @subject('{{ noun | capitalize }}').should.eql 'Fire'

      context 'past', ->
        Then -> @subject('{{ verb | past }}').should.eql 'finagled'

      context 'past particple', ->
        Then -> @subject('{{ verb | past_participle }}').should.eql 'finagled'

      context 'conjugate', ->
        Then -> @subject('{{ verb | conjugate("he") }}').should.eql 'finagles'

    context 'with pre filters', ->
      afterEach -> _.random.restore()
      Given -> sinon.stub(_, 'random').returns 0

      context 'startsWith', ->
        Then -> @subject('{{ noun : startsWith("a") }}').should.eql 'alley'

      context 'endsWith', ->
        Then -> @subject('{{ noun : endsWith("t") }}').should.eql 'sheet'

      context 'contains', ->
        Then -> @subject('{{ noun : contains("u") }}').should.eql 'biscuit'

      context 'matching', ->

      context 'greaterThan', ->
        
      context 'lessThan', ->

      context 'saveAs', ->

      context 'include', ->

    context 'with both pre and post filters', ->
      afterEach -> _.random.restore()
      Given -> sinon.stub(_, 'random').returns 0
      Then -> @subject('{{ noun : startsWith("s") | capitalize }}').should.eql 'Sheet'

    context 'called with a count', ->
      Then -> @subject('{{ noun }}', 5).length.should.eql 5
