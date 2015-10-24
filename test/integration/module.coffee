sinon = require 'sinon'
_ = require 'lodash'
words = require '../../lib/words'
clear = require 'clear-require'

describe 'whimsy required as a module', ->
  Given -> @words = words.get()
  Given -> @subject = require '../../lib/whimsy'

  describe '.noun', ->
    context 'no options', ->
      Then -> @subject.noun().should.be.oneOf @words.noun

    context 'with a count', ->
      When -> @generated = @subject.noun({ count: 2 })
      Then ->
        @generated.should.be.an.instanceof(Array)
        @generated.length.should.eql 2

  describe '.verb', ->
    context 'no options', ->
      Then -> @subject.verb().should.be.oneOf @words.verb

    context 'with a count', ->
      When -> @generated = @subject.verb({ count: 2 })
      Then ->
        @generated.should.be.an.instanceof(Array)
        @generated.length.should.eql 2
    
  describe '.adjective', ->
    context 'no options', ->
      Then -> @subject.adjective().should.be.oneOf @words.adjective

    context 'with a count', ->
      When -> @generated = @subject.adjective({ count: 2 })
      Then ->
        @generated.should.be.an.instanceof(Array)
        @generated.length.should.eql 2
     
  describe '.adverb', ->
    context 'no options', ->
      Then -> @subject.adverb().should.be.oneOf @words.adverb

    context 'with a count', ->
      When -> @generated = @subject.adverb({ count: 2 })
      Then ->
        @generated.should.be.an.instanceof(Array)
        @generated.length.should.eql 2
    
  describe '.pronoun', ->
    context 'top level', ->
      Then -> @subject.pronoun().should.be.oneOf _(@words.pronoun).values().flatten().value()

    context 'nested', ->
      Then -> @subject.pronoun('reflexive').should.be.oneOf @words.pronoun.reflexive

    context 'with a count', ->
      When -> @generated = @subject.pronoun('reflexive', { count: 2 })
      Then ->
        @generated.should.be.an.instanceof(Array)
        @generated.length.should.eql 2
    
  describe '.preposition', ->
    context 'no options', ->
      Then -> @subject.preposition().should.be.oneOf @words.preposition

    context 'with a count', ->
      When -> @generated = @subject.preposition({ count: 2 })
      Then ->
        @generated.should.be.an.instanceof(Array)
        @generated.length.should.eql 2
    
  describe '.conjunction', ->
    context 'top level', ->
      Then -> @subject.conjunction().should.be.oneOf _(@words.conjunction).values().flatten().value()

    context 'nested', ->
      Then -> @subject.conjunction('correlative').should.be.oneOf @words.conjunction.correlative

    context 'with a count', ->
      When -> @generated = @subject.conjunction({ count: 2 })
      Then ->
        @generated.should.be.an.instanceof(Array)
        @generated.length.should.eql 2
    
  describe '.interjection', ->
    context 'no options', ->
      Then -> @subject.interjection().should.be.oneOf @words.interjection

    context 'with a count', ->
      When -> @generated = @subject.interjection({ count: 2 })
      Then ->
        @generated.should.be.an.instanceof(Array)
        @generated.length.should.eql 2
    
  describe '.article', ->
    context 'no options', ->
      Then -> @subject.article().should.be.oneOf @words.article

    context 'with a count', ->
      When -> @generated = @subject.article({ count: 2 })
      Then ->
        @generated.should.be.an.instanceof(Array)
        @generated.length.should.eql 2
    
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

    context 'with filters:', ->
      afterEach -> _.random.restore()
      Given -> sinon.stub(_, 'random').returns 0

      context 'post', ->
        context 'pluralize', ->
          Then -> @subject('{{ noun | pluralize }}').should.eql 'fires'
        
        context 'capitalize', ->
          Then -> @subject('{{ noun | capitalize }}').should.eql 'Fire'

        context 'past', ->
          Then -> @subject('{{ verb | past }}').should.eql 'finagled'

        context 'past particple', ->
          Then -> @subject('{{ verb | pastParticiple }}').should.eql 'finagled'

        context 'conjugate', ->
          Then -> @subject('{{ verb | conjugate("he") }}').should.eql 'finagles'

      context 'pre', ->
        context 'startsWith', ->
          Then -> @subject('{{ noun | startsWith("a") }}').should.eql 'alley'

        context 'endsWith', ->
          Then -> @subject('{{ noun | endsWith("t") }}').should.eql 'sheet'

        context 'contains', ->
          Then -> @subject('{{ noun | contains("u") }}').should.eql 'biscuit'

        context 'matching', ->
          Then -> @subject('{{ noun | matching("[aeiou]{2,}") }}').should.eql 'sheet'

        context 'greaterThan', ->
          Then -> @subject('{{ noun | greaterThan(5) }}').should.eql 'prophecy'
          
        context 'lessThan', ->
          Then -> @subject('{{ noun | lessThan(4) }}').should.eql 'wit'

        context 'saveAs', ->
          context 'no filter on reuse', ->
            Then -> @subject('{{ noun | saveAs("blah") }}|{{ blah }}').should.eql 'fire|fire'

          context 'with a filter on reuse', ->
            Then -> @subject('{{ noun | saveAs("blah") }}|{{ blah | capitalize }}').should.eql 'fire|Fire'

        context 'include', ->
          context 'with an array', ->
            Given -> _.random.returns 7
            Then -> @subject('{{ conjunction.coordinating | include(["foo"]) }}').should.eql 'foo'

          context 'with a string', ->
            Given -> _.random.returns 7
            Then -> @subject('{{ conjunction.coordinating | include("foo") }}').should.eql 'foo'

        context 'exclude', ->
          context 'with an array', ->
            Then -> @subject('{{ noun | exclude(["fire"]) }}').should.eql 'sheet'

      context 'with both pre and post filters', ->
        context 'in the right order', ->
          Then -> @subject('{{ noun | startsWith("s") | capitalize }}').should.eql 'Sheet'

        context 'not in the right order', ->
          Then -> @subject('{{ noun | capitalize | startsWith("s") }}').should.eql 'Sheet'

      context 'with registered filters', ->
        context 'post filter', ->
          When -> @subject.register 'reverse', (word) ->
            return word.split('').reverse().join('')
          Then -> @subject('{{ noun | reverse }}').should.eql 'erif'

        context 'pre filter', ->
          context 'with no additional args', ->
            When -> @subject.register 'containingU', (list) ->
              return _.filter list, (item) ->
                return item.indexOf('u') > -1
            , true
            Then -> @subject('{{ noun | containingU }}').should.eql 'biscuit'
          
          context 'with additional args', ->
            When -> @subject.register 'containing', (letter, list) ->
              return _.filter list, (item) ->
                return item.indexOf(letter) > -1
            , true
            Then -> @subject('{{ noun | containing("u") }}').should.eql 'biscuit'

    context 'called with a count', ->
      Then -> @subject('{{ noun }}', 5).length.should.eql 5
