{MockDate} = require('../lib/karen')

describe 'MockDate', ->
  describe '#setTime/#getTime', ->
    it 'sets and gets time', ->
      date = new Date(2010, 1, 2, 12, 22, 15)
      date1 = new MockDate
      date2 = new MockDate(2014, 11, 24, 15, 0, 0)
      date1.getTime().should.not.equal(date2.getTime())
      date1.setTime(date.getTime())
      date2.setTime(date.getTime())
      date1.getTime().should.equal(date.getTime())
      date2.getTime().should.equal(date.getTime())

  describe '#setUTCDate/#getUTCDate', ->
    it 'sets and gets UTC date', ->
      date = new MockDate(2014, 11, 24, 15, 0, 0)
      date.getUTCDate().should.equal(24)
      date.setUTCDate(10)
      date.getUTCDate().should.equal(10)

  describe '#setMinutes/#getMinutes', ->
    it 'sets and gets minutes', ->
      date = new MockDate(2014, 11, 24, 15, 0, 0)
      date.getMinutes().should.equal(0)
      date.setMinutes(10)
      date.getMinutes().should.equal(10)

  ['toUTCString', 'getTimezoneOffset'].forEach (fnName) ->
    describe '#' + fnName, ->
      it 'is inherited from date', ->
        realDate = new Date(2014, 11, 24, 15, 0, 0)
        mockDate = new MockDate(2014, 11, 24, 15, 0, 0)
        actual = realDate[fnName]()
        expected = mockDate[fnName]()
        expected.should.equal(actual)

  describe '.add', ->
    it 'adds offset to instances created (without arguments) after', ->
      date1 = new MockDate
      MockDate.add(100)
      date2 = new MockDate
      (date2.getTime() - date1.getTime()).should.equal(100)
