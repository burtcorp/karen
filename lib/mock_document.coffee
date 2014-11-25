Evented = require('./evented')

class MockDocument extends Evented
  constructor: ->
    super

    cookies = {}

    @__defineGetter__ 'cookie', ->
      cookieString = []

      for name, value of cookies
        cookieString.push(name + '=' + value.value)

      cookieString.join('; ')

    @__defineSetter__ 'cookie', (value) ->
      [keyValue, options...] = value.split(';').map (part) -> part.trim()
      [key, value] = keyValue.split('=')

      cookies[key] =
        value: value

      for option in options
        [optionName, optionValue] = option.split('=')

        cookies[key][optionName] = optionValue

      @emit 'cookie', key, value, {path, domain} = cookies[key]

module.exports = MockDocument
