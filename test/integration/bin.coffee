clear = require 'clear-require'

describe 'whimsy as a command line binary', ->
  Given -> @spawn = require('child_process').spawn

  describe '.add', ->
    Given -> clear '../../lib/parts-of-speech'
    When (done) -> @child = @spawn 'whimsy', ['add', 'noun', 'blerg']
    Then -> require('../../lib/parts-of-speech').noun.should.contain('blerg')
