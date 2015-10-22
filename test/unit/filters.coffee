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
