should = require('should')
should.Assertion.addChain('been')

global.proxyquire = require('proxyquire').noCallThru()
