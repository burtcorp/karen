{MockNode} = require('../lib/karen')

describe 'MockNode', ->
  def 'node', -> new MockNode
  def 'window', -> @node.ownerDocument.defaultView

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

  describe '#removeChild', ->
    it 'emits remove-child event with node when child has been added', (done) ->
      node = {}
      @node.on 'remove-child', (child) ->
        done() if child == node
      @node.appendChild(node)
      @node.removeChild(node)

    it 'does not emit remove-child event when child has not been added', (done) ->
      node = {}
      @node.on 'remove-child', ->
        done('should not have emit event, but did')
      @node.removeChild(node)
      done()

  describe '#getAttribute/#setAttribute', ->
    it 'allows to read and write attributes', ->
      @node.setAttribute('foo', 'bar')
      @node.setAttribute('baz', 'qux')
      @node.getAttribute('foo').should.equal('bar')
      @node.getAttribute('baz').should.equal('qux')

  describe '#getBoundingClientRect', ->
    beforeEach ->
      @boundingClientRect = @node.getBoundingClientRect()

    describe '#height', ->
      it 'is zero by default', ->
        @boundingClientRect.height.should.equal(0)

    describe '#width', ->
      it 'is zero by default', ->
        @boundingClientRect.width.should.equal(0)

    describe '#left', ->
      it 'is based on the window left scroll', ->
        @node.getBoundingClientRect().left.should.equal(0)
        @window.scrollTo(100, 0)
        @node.getBoundingClientRect().left.should.equal(-100)

    describe '#bottom', ->
      it 'is zero by default', ->
        @boundingClientRect.bottom.should.equal(0)

    describe '#right', ->
      it 'is zero by default', ->
        @boundingClientRect.right.should.equal(0)

    describe '#top', ->
      it 'is based on the window top scroll', ->
        @node.getBoundingClientRect().top.should.equal(0)
        @window.scrollTo(0, 100)
        @node.getBoundingClientRect().top.should.equal(-100)

  describe '#scrollTop', ->
    it 'returns scroll top', ->
      @node.scrollTop.should.equal(0)

  describe '#scrollLeft', ->
    it 'returns scroll left', ->
      @node.scrollLeft.should.equal(0)

  describe '#scrollWidth', ->
    it 'returns scroll width', ->
      @node.scrollWidth.should.equal(1265)

  describe '#scrollHeight', ->
    it 'returns scroll height', ->
      @node.scrollHeight.should.equal(2284)

  describe '#clientWidth', ->
    it 'returns client width', ->
      @node.clientWidth.should.equal(1265)

  describe '#clientHeight', ->
    it 'returns client height', ->
      @node.clientHeight.should.equal(2284)

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

  describe '#getElementsByTagName', ->
    it 'returns an empty array', ->
      @node.getElementsByTagName('div').should.eql([])

  describe '#insertBefore', ->
    it 'does nothing but exist', ->
      @node.insertBefore({})
