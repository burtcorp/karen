{MockScreen} = require('../lib/karen')

describe 'MockScreen', ->
  def 'screen', -> new MockScreen

  describe '#width', ->
    it 'returns width', ->
      @screen.width.should.equal(2560)

  describe '#height', ->
    it 'returns height', ->
      @screen.height.should.equal(1440)
