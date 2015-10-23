describe 'filters', ->
  Given -> @subject = require '../../lib/filters'

  describe '.noop', ->
    Then -> @subject.noop('banana').should.eql 'banana'

  describe '.pluralize', ->
    Then -> @subject.pluralize('banana').should.eql 'bananas'

  describe '.capitalize', ->
    Then -> @subject.capitalize('banana').should.eql 'Banana'

  describe '.past', ->
    Then -> @subject.past('go').should.eql 'went'

  describe '.pastParticiple', ->
    Then -> @subject.pastParticiple('go').should.eql 'gone'

  describe '.conjugate', ->
    context 'third person', ->
      Then -> @subject.conjugate('he', 'run').should.eql 'runs'

    context 'not third person', ->
      Then -> @subject.conjugate('you', 'run').should.eql 'run'

  describe '.startsWith', ->
    Then -> @subject.startsWith('f', ['foo', 'bar', 'baz']).should.eql ['foo']

  describe '.endsWith', ->
    Then -> @subject.endsWith('s', ['blah', 'peels']).should.eql ['peels']

  describe '.contains', ->
    Then -> @subject.contains('s', ['bassinet', 'swoon', 'help']).should.eql ['bassinet', 'swoon']

  describe '.matching', ->
    Then -> @subject.matching('d$', ['beef', 'food', 'mud']).should.eql ['food', 'mud']

  describe '.greaterThan', ->
    Then -> @subject.greaterThan(3, ['foo', 'bar', 'baz', 'quux']).should.eql ['quux']

  describe '.lessThan', ->
    Then -> @subject.lessThan(4, ['foo', 'bar', 'baz', 'quux']).should.eql ['foo', 'bar', 'baz']

  describe '.saveAs', ->
    When -> @subject.saveAs('foo', 'bar')
    Then -> @subject._refs.should.eql
      foo: 'bar'

  describe '.include', ->
    context 'with an array', ->
      Then -> @subject.include(['baz', 'quux'], ['foo', 'bar']).should.eql ['foo', 'bar', 'baz', 'quux']

    context 'with a string', ->
      Then -> @subject.include('baz', ['foo', 'bar']).should.eql ['foo', 'bar', 'baz']

  describe '.exclude', ->
    context 'with an array', ->
      Then -> @subject.exclude(['foo', 'baz'], ['foo', 'bar', 'baz']).should.eql ['bar']

    context 'with an array', ->
      Then -> @subject.exclude('foo', ['foo', 'bar']).should.eql ['bar']
