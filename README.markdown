# Karen

Karen is a collection of mock objects, for example window, document
and node.

## Installation

```bash
$ npm install karen --save-dev
```

## API

These are the main mock objects:

  * `MockWindow`
  * `MockDocument`
  * `MockElement`
  * `MockNode`
  * `MockLocation`
  * `MockNavigator`
  * `MockScreen`
  * `MockDate`

See code/tests for resp class on how to use.

## Usage

As a simple example, let's say we want to add some syntactic sugar
around `setTimeout`, with the following API:

```coffee
timer = Timer(window)
timer.delay 100, -> # do something

on 'event', ->
  timer.stop()
```

Here is the implementation of `Timer`:

```coffee
Timer = (window) ->
  delay: (ms, callback) ->
    timeout = window.setTimeout(callback, ms)

    stop: ->
      window.clearTimeout(timeout)
```

And a simple test using [Mocha.js](http://mochajs.org/):

```coffee
describe 'Timer', ->
  it 'runs callback', (done) ->
    mockWindow = new MockWindow
    timer = Timer(mockWindow)
    timer.delay(100, done)
    mockWindow.tick(100)
```

## Copyright

© 2014-2015 Burt AB, see LICENSE.txt (BSD 3-Clause).
