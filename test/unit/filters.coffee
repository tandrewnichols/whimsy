describe 'filters', ->
  Given -> @subject = require '../../lib/filters'

  describe '.pluralize', ->
    Then -> @subject.pluralize('banana').should.eql 'bananas'

  describe '.capitalize', ->
    Then -> @subject.capitalize('banana').should.eql 'Banana'
