sinon = require 'sinon'

describe 'words', ->
  Given -> @partsOfSpeech =
    foo: ['bar', 'baz']
  Given -> @subject = proxyquire '../../lib/words',
    './parts-of-speech': @partsOfSpeech

  describe '.get', ->
    afterEach -> @subject.parse.restore()
    afterEach -> @subject.stringify.restore()
    Given -> sinon.stub @subject, 'parse'
    Given -> sinon.stub @subject, 'stringify'

    context 'already arrays', ->
      When -> @lists = @subject.get()
      Then -> @lists.should.eql @partsOfSpeech

    context 'strings', ->
      Given -> @partsOfSpeech.foo = 'bar, baz'
      Given -> @subject.parse.withArgs(@partsOfSpeech).returns 'blah'
      When -> @lists = @subject.get()
      Then -> @lists.should.eql 'blah'

  describe '.parse', ->
    Given -> @obj =
      foo: "blah, banana, chicken soup"
      bar:
        baz: "ellipsis, syrup, toga party"
        quux: "hello world"
    When -> @newObj = @subject.parse @obj
    Then -> @newObj.should.eql
      foo: ['blah', 'banana', 'chicken soup']
      bar:
        baz: ['ellipsis', 'syrup', 'toga party']
        quux: ['hello world']

  describe '.stringify', ->
    Given -> @obj =
      fruits: ['banana', 'apple', 'kiwi']
      people:
        threeNames: ['John Phillip Sousa', 'Phillip Seymour Hoffman']
        twoNames: ['Morgan Freeman']
    When -> @result = @subject.stringify @obj
    Then -> @result.should.eql JSON.stringify
      fruits: "banana, apple, kiwi"
      people:
        threeNames: "John Phillip Sousa, Phillip Seymour Hoffman"
        twoNames: "Morgan Freeman"
    , null, 2
