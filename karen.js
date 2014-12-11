(function() {
  var Evented, MockDocument, MockElement, MockLocation, MockNavigator, MockNode, MockScreen, MockWindow, api, key, value,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Evented = (function() {
    function Evented() {
      this.listeners = {};
    }

    Evented.prototype.on = function(event, listener) {
      var _base;
      if ((_base = this.listeners)[event] == null) {
        _base[event] = [];
      }
      return this.listeners[event].push(listener);
    };

    Evented.prototype.emit = function() {
      var args, event, listener, _i, _len, _ref, _results;
      event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _ref = this.listeners[event] || [];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        listener = _ref[_i];
        _results.push(listener.apply(null, args));
      }
      return _results;
    };

    Evented.prototype.remove = function(event, listener) {
      var index;
      index = (this.listeners[event] || []).indexOf(listener);
      if (index !== -1) {
        return this.listeners[event].splice(index, 1);
      }
    };

    return Evented;

  })();

  MockLocation = (function() {
    function MockLocation() {}

    MockLocation.prototype.search = '';

    MockLocation.prototype.href = 'http://localhost';

    MockLocation.prototype.pathname = '/';

    return MockLocation;

  })();

  MockNavigator = (function() {
    function MockNavigator() {}

    MockNavigator.prototype.userAgent = '';

    return MockNavigator;

  })();

  MockScreen = (function() {
    function MockScreen() {}

    MockScreen.prototype.width = 0;

    MockScreen.prototype.height = 0;

    return MockScreen;

  })();

  MockElement = (function(_super) {
    __extends(MockElement, _super);

    function MockElement(type) {
      this.type = type;
      MockElement.__super__.constructor.call(this);
    }

    MockElement.prototype.define = function(name, callback) {
      var cache;
      cache = this.cache != null ? this.cache : this.cache = {};
      return Object.defineProperty(this, name, {
        get: function() {
          if (cache[name] === void 0) {
            return cache[name] = callback();
          } else {
            return cache[name];
          }
        },
        set: function(value) {
          return cache[name] = value;
        }
      });
    };

    MockElement.prototype.addEventListener = function(event, listener) {
      return this.on(event, listener);
    };

    MockElement.prototype.removeEventListener = function(event, listener) {
      return this.remove(event, listener);
    };

    MockElement.prototype.attachEvent = function(event, listener) {
      return this.on(event, listener);
    };

    MockElement.prototype.detachEvent = function(event, listener) {
      return this.remove(event, listener);
    };

    return MockElement;

  })(Evented);

  MockNode = (function(_super) {
    __extends(MockNode, _super);

    function MockNode(type) {
      MockNode.__super__.constructor.apply(this, arguments);
      if ((type != null ? type.toLowerCase() : void 0) === 'iframe') {
        this.contentWindow = new MockWindow;
      }
      this.attributes = {};
      this.define('ownerDocument', function() {
        return new MockDocument;
      });
      this.define('parentNode', function() {
        return new MockNode;
      });
      this.children = [];
    }

    MockNode.prototype.style = {};

    MockNode.prototype.createElement = function(type) {
      return new MockNode(type);
    };

    MockNode.prototype.appendChild = function(node) {
      this.children.push(node);
      return this.emit('append-child', node);
    };

    MockNode.prototype.removeChild = function(node) {
      if (__indexOf.call(this.children, node) >= 0) {
        return this.emit('remove-child', node);
      }
    };

    MockNode.prototype.getBoundingClientRect = function() {
      return {
        height: 0,
        width: 0,
        left: 0,
        bottom: 0,
        right: 0,
        top: 0
      };
    };

    MockNode.prototype.setAttribute = function(name, value) {
      return this.attributes[name] = value;
    };

    MockNode.prototype.getAttribute = function(name) {
      return this.attributes[name];
    };

    MockNode.prototype.getElementsByTagName = function() {
      return [];
    };

    MockNode.prototype.insertBefore = function(other) {};

    return MockNode;

  })(MockElement);

  MockDocument = (function(_super) {
    __extends(MockDocument, _super);

    function MockDocument() {
      var cookies;
      MockDocument.__super__.constructor.call(this, 'document');
      cookies = {};
      this.__defineGetter__('cookie', function() {
        var cookieString, name, value;
        cookieString = [];
        for (name in cookies) {
          value = cookies[name];
          cookieString.push(name + '=' + value.value);
        }
        return cookieString.join('; ');
      });
      this.__defineSetter__('cookie', function(value) {
        var domain, key, keyValue, option, optionName, optionValue, options, path, _i, _len, _ref, _ref1, _ref2, _ref3;
        _ref = value.split(';').map(function(part) {
          return part.trim();
        }), keyValue = _ref[0], options = 2 <= _ref.length ? __slice.call(_ref, 1) : [];
        _ref1 = keyValue.split('='), key = _ref1[0], value = _ref1[1];
        cookies[key] = {
          value: value
        };
        for (_i = 0, _len = options.length; _i < _len; _i++) {
          option = options[_i];
          _ref2 = option.split('='), optionName = _ref2[0], optionValue = _ref2[1];
          cookies[key][optionName] = optionValue;
        }
        return this.emit('cookie', key, value, (_ref3 = cookies[key], path = _ref3.path, domain = _ref3.domain, _ref3));
      });
      this.define('defaultView', function() {
        return new MockWindow;
      });
      this.define('parentWindow', function() {
        return new MockWindow;
      });
      this.define('body', function() {
        return new MockNode('body');
      });
      this.define('head', function() {
        return new MockNode('head');
      });
      this.define('documentElement', function() {
        return new MockNode('documentElement');
      });
    }

    MockDocument.prototype.domain = 'localhost';

    MockDocument.prototype.readyState = 'complete';

    MockDocument.prototype.getElementById = function() {
      return null;
    };

    return MockDocument;

  })(MockNode);

  MockWindow = (function(_super) {
    __extends(MockWindow, _super);

    function MockWindow() {
      MockWindow.__super__.constructor.call(this, 'window');
      this.timeouts = [];
      this.intervals = [];
      this.currentTime = 0;
      this.top = this;
      this.console = {
        log: (function(_this) {
          return function() {
            var args;
            args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            return _this.emit.apply(_this, ['console-log'].concat(__slice.call(args)));
          };
        })(this)
      };
      this.define('document', function() {
        return new MockDocument;
      });
      this.define('location', function() {
        return new MockLocation;
      });
      this.define('navigator', function() {
        return new MockNavigator;
      });
      this.define('screen', function() {
        return new MockScreen;
      });
    }

    MockWindow.prototype.postMessage = function(data, origin) {
      return this.emit('message', {
        data: data,
        origin: origin,
        source: this
      });
    };

    MockWindow.prototype.decodeURIComponent = decodeURIComponent;

    MockWindow.prototype.encodeURIComponent = encodeURIComponent;

    MockWindow.prototype.setTimeout = function(callback, delay) {
      delay = Math.floor(delay);
      return this.timeouts.push({
        timeout: true,
        runAt: this.currentTime + delay,
        callback: callback
      });
    };

    MockWindow.prototype.setInterval = function(callback, delay) {
      delay = Math.floor(delay);
      return this.intervals.push({
        interval: true,
        delay: delay,
        runAt: this.currentTime + delay,
        callback: callback
      });
    };

    MockWindow.prototype.clearTimeout = function(index) {
      var timeout;
      if (timeout = this.timeouts[index - 1]) {
        return timeout.cleared = true;
      }
    };

    MockWindow.prototype.clearInterval = function(index) {
      var interval;
      if (interval = this.intervals[index - 1]) {
        return interval.cleared = true;
      }
    };

    MockWindow.prototype.tick = function(ms, callback) {
      var asyncOrSync, current, nextToRun;
      ms = Math.floor(ms);
      nextToRun = (function(_this) {
        return function() {
          var candidate, candidates, item, minItem, minValue, _i, _j, _len, _len1, _ref;
          candidates = [];
          _ref = _this.timeouts.concat(_this.intervals);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            item = _ref[_i];
            if (_this.currentTime + ms < item.runAt) {
              continue;
            }
            if (item.cleared) {
              continue;
            }
            if (item.interval) {
              candidates.push(item);
            } else if (item.timeout) {
              if (!item.callbacked) {
                candidates.push(item);
              }
            }
          }
          minItem = null;
          minValue = null;
          for (_j = 0, _len1 = candidates.length; _j < _len1; _j++) {
            candidate = candidates[_j];
            if (!(minItem && candidate.runAt >= minValue)) {
              minItem = candidate;
              minValue = candidate.runAt;
            }
          }
          return minItem;
        };
      })(this);
      asyncOrSync = function(fn) {
        if (callback) {
          return setTimeout(fn, 0);
        } else {
          return fn();
        }
      };
      if (current = nextToRun()) {
        return asyncOrSync((function(_this) {
          return function() {
            var currentTime, tick;
            currentTime = _this.currentTime;
            _this.currentTime = current.runAt;
            tick = ms + currentTime - current.runAt;
            if (current.interval) {
              current.runAt += current.delay;
            } else {
              current.callbacked = true;
            }
            current.callback();
            if (tick >= 0) {
              return _this.tick(tick, callback);
            }
          };
        })(this));
      } else {
        this.currentTime += ms;
        if (callback) {
          return callback();
        }
      }
    };

    MockWindow.prototype.tickAsync = function(ms, callback) {
      if (callback == null) {
        callback = function() {};
      }
      return this.tick(ms, callback);
    };

    MockWindow.prototype.setImmediate = function() {
      var callback, params;
      callback = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return setImmediate.apply(null, [callback].concat(__slice.call(params)));
    };

    return MockWindow;

  })(MockElement);

  api = {
    Evented: Evented,
    MockWindow: MockWindow,
    MockDocument: MockDocument,
    MockElement: MockElement,
    MockNode: MockNode,
    MockLocation: MockLocation,
    MockNavigator: MockNavigator,
    MockScreen: MockScreen
  };

  if (typeof module !== "undefined" && module !== null) {
    module.exports = api;
  } else if (typeof window !== "undefined" && window !== null) {
    for (key in api) {
      value = api[key];
      window[key] = value;
    }
  }

}).call(this);
