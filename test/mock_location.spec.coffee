{MockLocation} = require('../lib/karen')

describe 'MockLocation', ->
  def 'location', -> new MockLocation

  describe '#search', ->
    it 'is empty', ->
      @location.search.should.equal('')

  describe '#href', ->
    it 'is localhost', ->
      @location.href.should.equal('http://localhost')

  describe '#pathname', ->
    it 'is root', ->
      @location.pathname.should.equal('/')
