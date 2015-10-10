should = require('should')
  
should.Assertion.add 'contain', (thing) ->
  this.params = operator: 'to contain'
  thing.should.be.oneOf(this.obj)

should.Assertion.addChain('been')
