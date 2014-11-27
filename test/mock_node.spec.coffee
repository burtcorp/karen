{MockNode} = require('../lib/karen')

describe 'MockNode', ->
  def 'node', -> new MockNode

  describe '#style', ->
    it 'allows for read/write styles', ->
      @node.style.background = 'red';
      @node.style.background.should.equal('red')

  describe '#appendChild', ->
    it 'emits append-child event with node as argument', (done) ->
      child = {}
      @node.on 'append-child', (node) ->
        done() if node == child
      @node.appendChild(child)

  describe '#getAttribute/#setAttribute', ->
    it 'allows to read and write attributes', ->
      @node.setAttribute('foo', 'bar')
      @node.setAttribute('baz', 'qux')
      @node.getAttribute('foo').should.equal('bar')
      @node.getAttribute('baz').should.equal('qux')

  describe 'getBoundingClientRect', ->
    beforeEach ->
      @boundingClientRect = @node.getBoundingClientRect()

    describe '#height', ->
      it 'returns node height', ->
        @boundingClientRect.height.should.equal(0)

    describe '#width', ->
      it 'returns node width', ->
        @boundingClientRect.width.should.equal(0)

    describe '#left', ->
      it 'returns node left', ->
        @boundingClientRect.left.should.equal(0)

    describe '#bottom', ->
      it 'returns node bottom', ->
        @boundingClientRect.bottom.should.equal(0)

    describe '#right', ->
      it 'returns node right', ->
        @boundingClientRect.right.should.equal(0)

    describe '#top', ->
      it 'returns node top', ->
        @boundingClientRect.top.should.equal(0)

  describe '#ownerDocument', ->
    it 'returns a MockDocument object', ->
      @node.ownerDocument.should.be.an('object')

    it 'returns same owner document every time', ->
      @node.ownerDocument.should.equal(@node.ownerDocument)

  describe '#parentNode', ->
    it 'returns a MockNode object', ->
      @node.parentNode.should.be.an('object')

    it 'returns same parent every time', ->
      @node.parentNode.should.equal(@node.parentNode)
