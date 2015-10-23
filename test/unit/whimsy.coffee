sinon = require 'sinon'
_ = require 'lodash'

describe 'whimsy', ->
  Given -> @lists =
    foo: ['a', 'b']
    bar:
      baz: ['quux']
  Given -> @words =
    get: => @lists
  Given -> @filters = require '../../lib/filters',
  Given -> @subject = proxyquire '../../lib/whimsy',
    './words': @words

  describe 'interpolation', ->
    afterEach -> @subject.interpolate.restore()
    Given -> sinon.stub(@subject, 'interpolate')

    context 'no duplicates', ->
      Given -> @subject.interpolate.withArgs('{{ adjective }}', 'adjective').returns 'illustrious'
      Given -> @subject.interpolate.withArgs('{{ noun }}', 'noun').returns 'chicken'
      Then -> @subject('The {{ adjective }} {{ noun }}').should.eql 'The illustrious chicken'

    context 'with duplicates', ->
      Given -> @subject.interpolate.onFirstCall().returns 'banana'
      Given -> @subject.interpolate.onSecondCall().returns 'apple'
      Then -> @subject('{{ noun }} and {{ noun }}').should.eql 'banana and apple'

    context 'with a count', ->
      Given -> @subject.interpolate.onFirstCall().returns 'foo'
      Given -> @subject.interpolate.onSecondCall().returns 'bar'
      Then -> @subject('{{ noun }}', 2).should.eql ['foo', 'bar']

  describe '.interpolate', ->
    afterEach -> @subject.makeFilters.restore()
    afterEach -> @subject.generate.restore()
    afterEach -> @subject.applyFilters.restore()
    Given -> sinon.stub @subject, 'makeFilters'
    Given -> sinon.stub @subject, 'generate'
    Given -> sinon.stub @subject, 'applyFilters'
    Given -> @filters.preFilters = ['inspect', 'peel']
    Given -> @filters.postFilters = ['eat', 'throw away']

    context 'no filters', ->
      Given -> @subject.makeFilters.withArgs(match: 'banana').returns []
      Given -> @subject.generate.withArgs('banana', []).returns 'yellow'
      Given -> @subject.applyFilters.withArgs('yellow', []).returns 'done'
      Then -> @subject.interpolate('{{ banana }}', 'banana').should.eql 'done'

    context 'with filters', ->
      Given -> @subject.makeFilters.withArgs(match: 'banana | peel | eat').returns [
        name: 'peel'
      ,
        name: 'eat'
      ]
      Given -> @subject.generate.withArgs('banana | peel | eat', [name: 'peel']).returns 'yellow'
      Given -> @subject.applyFilters.withArgs('yellow', [name: 'eat']).returns 'done'
      Then -> @subject.interpolate('{{ banana | pluralize }}', 'banana | peel | eat ').should.eql 'done'

  describe '.parse', ->
    afterEach -> delete @filters.foo
    Given -> @filters.foo = ->

    context 'no parens', ->
      Then -> @subject.parse('foo').should.eql
        name: 'foo'
        params: []

    context 'parens already there', ->
      Then -> @subject.parse('foo()').should.eql
        name: 'foo'
        params: []

    context 'parens with a parameter', ->
      context '- a simple string', ->
        Then -> @subject.parse('foo("bar")').should.eql
          name: 'foo'
          params: ['bar']

      context '- a string with a comma in it', ->
        Then -> @subject.parse('foo("bar, baz", "blah")').should.eql
          name: 'foo'
          params: ['bar, baz', 'blah']

      context '- a number', ->
        Then -> @subject.parse('foo(5, "blah, blah", "bar")').should.eql
          name: 'foo'
          params: [5, 'blah, blah', 'bar']

      context '- an array', ->
        Then -> @subject.parse('foo(["a", "b", "c"], "bar")').should.eql
          name: 'foo'
          params: [["a", "b", "c"], "bar"]

      context '- an object', ->
        Then -> @subject.parse('foo({ "a": "b" }, "bar")').should.eql
          name: 'foo'
          params: [{ "a": "b" }, "bar"]

    context 'function is not a filter', ->
      Then -> @subject.parse('bar()').should.eql
        name: 'noop'
        params: []

  describe '.makeFilters', ->
    afterEach -> @subject.parse.restore()
    Given -> sinon.stub(@subject, 'parse')
    Given -> @subject.parse.withArgs('bar').returns 'a bar filter'
    Given -> @subject.parse.withArgs('baz').returns 'a baz filter'
    Given -> @obj = { match: 'foo|bar | baz' }
    Then -> @subject.makeFilters(@obj).should.eql ['a bar filter', 'a baz filter']

  describe '.applyFilters', ->
    Given -> @filters.foo = (word) -> _.capitalize(word)
    Given -> @filters.bar = (count, word) -> _.pad(word, count)
    Then -> @subject.applyFilters('banana', [
      name: 'foo'
      params: []
    ,
      name: 'bar'
      params: [9]
    ]).should.eql ' Banana  '

  describe '.invokeFilter', ->
    Given -> @filters.peel = sinon.stub()
    When -> @subject.invokeFilter 'current value',
      name: 'peel'
      params: [1, 2]
    Then -> @filters.peel.should.have.been.calledWith( 1, 2, 'current value')

  describe '.concat', ->
    context 'type exists', ->
      Then -> @subject.concat('banana', 'peel').should.eql 'banana.peel'

    context 'type does not exist', ->
      Then -> @subject.concat('banana', undefined).should.eql 'banana'

  describe '.generate', ->
    afterEach -> @subject.get.restore()
    Given -> sinon.stub(@subject, 'get')

    context 'as a literal array', ->
      Given -> @lists.banana = ['foo', 'bar', 'foo']
      Given -> @subject.get.withArgs(['foo', 'bar']).returns 'foo'
      Then -> @subject.generate('banana').should.eql 'foo'

    context 'as an object of arrays', ->
      Given -> @lists.fruits =
        banana: ['foo', 'bar']
        apple: ['baz', 'quux', 'foo']
      Given -> @subject.get.withArgs(['foo', 'bar', 'baz', 'quux']).returns 'foo'
      Then -> @subject.generate('fruits').should.eql 'foo'

    context 'nested property', ->
      Given -> @lists.fruits =
        banana: ['foo', 'bar']
        apple: ['baz', 'quux', 'foo']
      Given -> @subject.get.withArgs(['foo', 'bar']).returns 'foo'
      Then -> @subject.generate('fruits.banana').should.eql 'foo'

    context 'with pre filters', ->
      Given -> @filter =
        name: 'blah'
        params: ['banana']
      Given -> @filters.blah = sinon.stub()
      Given -> @lists.banana = ['foo', 'bar']
      When -> @subject.generate('banana', [@filter])
      Then -> @filters.blah.should.have.been.calledWith('banana', ['foo', 'bar'])

  describe '.get', ->
    afterEach -> _.random.restore()
    Given -> sinon.stub(_, 'random').withArgs(3).returns 2
    Then -> @subject.get([1,2,3,4]).should.eql 3

  describe '.register', ->
    context 'post filter', ->
      When -> @subject.register 'foo', 'bar'
      Then -> @filters.foo.should.eql 'bar'
      And -> 'foo'.should.be.oneOf @filters.postFilters

    context 'pre filter', ->
      When -> @subject.register 'foo', 'bar', true
      Then -> @filters.foo.should.eql 'bar'
      And -> 'foo'.should.be.oneOf @filters.preFilters

  describe 'parts of speech', ->
    afterEach -> @subject.generate.restore()
    Given -> sinon.stub(@subject, 'generate')

    describe '.noun', ->
      Given -> @subject.generate.withArgs('noun').returns 'banana'
      Then -> @subject.noun().should.eql 'banana'

    describe '.verb', ->
      Given -> @subject.generate.withArgs('verb').returns 'banana'
      Then -> @subject.verb().should.eql 'banana'

    describe '.adjective', ->
      Given -> @subject.generate.withArgs('adjective').returns 'banana'
      Then -> @subject.adjective().should.eql 'banana'

    describe '.adverb', ->
      Given -> @subject.generate.withArgs('adverb').returns 'banana'
      Then -> @subject.adverb().should.eql 'banana'

    describe '.pronoun', ->
      context 'top level', ->
        Given -> @subject.generate.withArgs('pronoun').returns 'banana'
        Then -> @subject.pronoun().should.eql 'banana'

      context 'nested', ->
        Given -> @subject.generate.withArgs('pronoun.banana').returns 'banana'
        Then -> @subject.pronoun('banana').should.eql 'banana'

    describe '.preposition', ->
      Given -> @subject.generate.withArgs('preposition').returns 'banana'
      Then -> @subject.preposition().should.eql 'banana'

    describe '.conjunction', ->
      context 'top level', ->
        Given -> @subject.generate.withArgs('conjunction').returns 'banana'
        Then -> @subject.conjunction().should.eql 'banana'

      context 'nested', ->
        Given -> @subject.generate.withArgs('conjunction.banana').returns 'banana'
        Then -> @subject.conjunction('banana').should.eql 'banana'

    describe '.interjection', ->
      Given -> @subject.generate.withArgs('interjection').returns 'banana'
      Then -> @subject.interjection().should.eql 'banana'

    describe '.article', ->
      Given -> @subject.generate.withArgs('article').returns 'banana'
      Then -> @subject.article().should.eql 'banana'
