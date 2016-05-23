(function() {
  var Evented, MockDate, MockDocument, MockElement, MockEvent, MockLocation, MockNavigator, MockNode, MockScreen, MockWindow, api, key, value,
    slice = [].slice,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Evented = (function() {
    function Evented() {
      this.listeners = {};
    }

    Evented.prototype.on = function(event, listener) {
      var base;
      if ((base = this.listeners)[event] == null) {
        base[event] = [];
      }
      return this.listeners[event].push(listener);
    };

    Evented.prototype.emit = function() {
      var args, event, i, len, listener, ref, results;
      event = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      ref = this.listeners[event] || [];
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        listener = ref[i];
        results.push(listener.apply(null, args));
      }
      return results;
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

  MockEvent = (function() {
    function MockEvent(type1) {
      this.type = type1;
    }

    return MockEvent;

  })();

  MockDate = (function() {
    function MockDate() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      if (args.length === 0) {
        args = [MockDate.__now.getTime()];
      }
      return new (Function.prototype.bind.apply(Date, [null].concat(args)));
    }

    return MockDate;

  })();

  MockDate.__now = new Date;

  MockDate.add = function(ms) {
    return MockDate.__now.setTime(MockDate.__now.getTime() + ms);
  };

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

    MockScreen.prototype.width = 2560;

    MockScreen.prototype.height = 1440;

    return MockScreen;

  })();

  MockElement = (function(superClass) {
    extend(MockElement, superClass);

    function MockElement(type1) {
      this.type = type1;
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

  MockNode = (function(superClass) {
    extend(MockNode, superClass);

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
      if (indexOf.call(this.children, node) >= 0) {
        return this.emit('remove-child', node);
      }
    };

    MockNode.prototype.getBoundingClientRect = function() {
      return {
        height: 100,
        width: 100,
        left: -this.ownerDocument.defaultView.pageXOffset,
        top: -this.ownerDocument.defaultView.pageYOffset
      };
    };

    MockNode.prototype.scrollTop = 0;

    MockNode.prototype.scrollLeft = 0;

    MockNode.prototype.scrollWidth = 1265;

    MockNode.prototype.scrollHeight = 2284;

    MockNode.prototype.clientWidth = 1265;

    MockNode.prototype.clientHeight = 2284;

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

  MockDocument = (function(superClass) {
    extend(MockDocument, superClass);

    function MockDocument() {
      var cookies, hasExpired;
      MockDocument.__super__.constructor.call(this, 'document');
      cookies = {};
      hasExpired = (function(_this) {
        return function(name) {
          var exp, expires, now;
          expires = cookies[name].expires;
          exp = (new _this.defaultView.Date(expires)).getTime();
          now = (new _this.defaultView.Date()).getTime();
          return now - exp > 0;
        };
      })(this);
      this.__defineGetter__('cookie', function() {
        var cookieString, expires, name, ref, value;
        cookieString = [];
        for (name in cookies) {
          ref = cookies[name], value = ref.value, expires = ref.expires;
          if (!hasExpired(name)) {
            cookieString.push(name + '=' + value);
          }
        }
        return cookieString.join('; ');
      });
      this.__defineSetter__('cookie', function(value) {
        var domain, expires, i, key, keyValue, len, option, optionName, optionValue, options, path, ref, ref1, ref2, ref3;
        ref = value.split(';').map(function(part) {
          return part.trim();
        }), keyValue = ref[0], options = 2 <= ref.length ? slice.call(ref, 1) : [];
        ref1 = keyValue.split('='), key = ref1[0], value = ref1[1];
        cookies[key] = {
          value: value
        };
        for (i = 0, len = options.length; i < len; i++) {
          option = options[i];
          ref2 = option.split('='), optionName = ref2[0], optionValue = ref2[1];
          cookies[key][optionName] = optionValue;
        }
        return this.emit('cookie', key, value, (ref3 = cookies[key], expires = ref3.expires, path = ref3.path, domain = ref3.domain, ref3));
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

  MockWindow = (function(superClass) {
    extend(MockWindow, superClass);

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
            args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            return _this.emit.apply(_this, ['console-log'].concat(slice.call(args)));
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

    MockWindow.prototype.Date = MockDate;

    MockWindow.prototype.scrollTo = function(x, y) {
      this.pageXOffset = x;
      this.pageYOffset = y;
      this.document.documentElement.scrollLeft = x;
      this.document.documentElement.scrollTop = y;
      this.document.body.scrollLeft = x;
      this.document.body.scrollTop = y;
      return this.emit('scroll', new MockEvent('scroll'));
    };

    MockWindow.prototype.pageXOffset = 0;

    MockWindow.prototype.pageYOffset = 0;

    MockWindow.prototype.innerWidth = 1280;

    MockWindow.prototype.innerHeight = 1086;

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
          var candidate, candidates, i, item, j, len, len1, minItem, minValue, ref;
          candidates = [];
          ref = _this.timeouts.concat(_this.intervals);
          for (i = 0, len = ref.length; i < len; i++) {
            item = ref[i];
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
          for (j = 0, len1 = candidates.length; j < len1; j++) {
            candidate = candidates[j];
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
        MockDate.add(current.runAt - this.currentTime);
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
        MockDate.add(ms);
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
      callback = arguments[0], params = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      return setImmediate.apply(null, [callback].concat(slice.call(params)));
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
    MockScreen: MockScreen,
    MockDate: MockDate,
    MockEvent: MockEvent
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
