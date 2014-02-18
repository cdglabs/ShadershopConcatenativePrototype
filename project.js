// Generated by CoffeeScript 1.6.3
/*

Need to snap to grid lines
  given a y value and a tolerance (pixels), find closest grid line (i.e. return a y value, either the same or snapped)

Need to see how close a point is to an object, for hit detection
*/


(function() {
  var Apply, Chain, Editor, Env, Fn, Graph, GraphView, Link, Param, PointerManager, StartLink, compose, config, cx, d, drawLine, editor, fnsToAdd, lerp, mainGraph, pointerManager, pointerdown, pointermove, pointerup, refresh, refreshView, resize, ticks, updateHover, _base, _ref, _ref1,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  config = {
    minGridSpacing: 70,
    hitTolerance: 15,
    snapTolerance: 5
  };

  ticks = function(spacing, min, max) {
    var first, last, x, _i, _results;
    first = Math.ceil(min / spacing);
    last = Math.floor(max / spacing);
    _results = [];
    for (x = _i = first; first <= last ? _i <= last : _i >= last; x = first <= last ? ++_i : --_i) {
      _results.push(x * spacing);
    }
    return _results;
  };

  drawLine = function(ctx, _arg, _arg1) {
    var x1, x2, y1, y2;
    x1 = _arg[0], y1 = _arg[1];
    x2 = _arg1[0], y2 = _arg1[1];
    ctx.beginPath();
    ctx.moveTo(x1, y1);
    ctx.lineTo(x2, y2);
    return ctx.stroke();
  };

  Graph = (function() {
    function Graph(canvas, xMin, xMax, yMin, yMax) {
      this.canvas = canvas;
      this.xMin = xMin;
      this.xMax = xMax;
      this.yMin = yMin;
      this.yMax = yMax;
      this.ctx = this.canvas.getContext("2d");
    }

    Graph.prototype.width = function() {
      return this.canvas.width;
    };

    Graph.prototype.height = function() {
      return this.canvas.height;
    };

    Graph.prototype.hitDetect = function(targetBrowserY, yValues) {
      var browserY, distance, found, i, minDistance, y, _i, _len;
      minDistance = config.hitTolerance;
      found = false;
      for (i = _i = 0, _len = yValues.length; _i < _len; i = ++_i) {
        y = yValues[i];
        browserY = this.fromLocal([0, y])[1];
        distance = Math.abs(browserY - targetBrowserY);
        if (distance < minDistance) {
          found = i;
          minDistance = distance;
        }
      }
      return found;
    };

    Graph.prototype.findSpacing = function() {
      var div, largeSpacing, minSpacing, sizeX, sizeY, smallSpacing, xMinSpacing, yMinSpacing, z;
      sizeX = this.xMax - this.xMin;
      sizeY = this.yMax - this.yMin;
      xMinSpacing = (sizeX / this.width()) * config.minGridSpacing;
      yMinSpacing = (sizeY / this.height()) * config.minGridSpacing;
      minSpacing = Math.max(xMinSpacing, yMinSpacing);
      /*
      need to determine:
        largeSpacing = {1, 2, or 5} * 10^n
        smallSpacing = divide largeSpacing by 4 (if 1 or 2) or 5 (if 5)
      largeSpacing must be greater than minSpacing
      */

      div = 4;
      largeSpacing = z = Math.pow(10, Math.ceil(Math.log(minSpacing) / Math.log(10)));
      if (z / 5 > minSpacing) {
        largeSpacing = z / 5;
      } else if (z / 2 > minSpacing) {
        largeSpacing = z / 2;
        div = 5;
      }
      smallSpacing = largeSpacing / div;
      return [largeSpacing, smallSpacing];
    };

    Graph.prototype.getCoords = function(_arg) {
      var browserX, browserY, rect, x, y;
      browserX = _arg[0], browserY = _arg[1];
      rect = this.canvas.getBoundingClientRect();
      x = lerp(browserX, rect.left, rect.right, this.xMin, this.xMax);
      y = lerp(browserY, rect.top, rect.bottom, this.yMax, this.yMin);
      return [x, y];
    };

    Graph.prototype.fromLocal = function(_arg) {
      var browserX, browserY, rect, x, y;
      x = _arg[0], y = _arg[1];
      rect = this.canvas.getBoundingClientRect();
      browserX = lerp(x, this.xMin, this.xMax, rect.left, rect.right);
      browserY = lerp(y, this.yMin, this.yMax, rect.bottom, rect.top);
      return [browserX, browserY];
    };

    Graph.prototype.clear = function() {
      return this.ctx.clearRect(0, 0, this.width(), this.height());
    };

    Graph.prototype.drawGrid = function() {
      var axesColor, axesOpacity, color, cx, cxMax, cxMin, cy, cyMax, cyMin, fromLocal, labelColor, labelDistance, labelOpacity, largeSpacing, majorColor, majorOpacity, minorColor, minorOpacity, sizeX, sizeY, smallSpacing, text, textHeight, toLocal, x, y, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8,
        _this = this;
      this.ctx.save();
      sizeX = this.xMax - this.xMin;
      sizeY = this.yMax - this.yMin;
      cxMin = 0;
      cxMax = this.width();
      cyMin = this.height();
      cyMax = 0;
      toLocal = function(_arg) {
        var cx, cy;
        cx = _arg[0], cy = _arg[1];
        return [lerp(cx, cxMin, cxMax, _this.xMin, _this.xMax), lerp(cy, cyMin, cyMax, _this.yMin, _this.yMax)];
      };
      fromLocal = function(_arg) {
        var x, y;
        x = _arg[0], y = _arg[1];
        return [lerp(x, _this.xMin, _this.xMax, cxMin, cxMax), lerp(y, _this.yMin, _this.yMax, cyMin, cyMax)];
      };
      labelDistance = 5;
      color = "0,0,0";
      minorOpacity = 0.1;
      majorOpacity = 0.2;
      axesOpacity = 0.5;
      labelOpacity = 1.0;
      textHeight = 12;
      minorColor = "rgba(" + color + ", " + minorOpacity + ")";
      majorColor = "rgba(" + color + ", " + majorOpacity + ")";
      axesColor = "rgba(" + color + ", " + axesOpacity + ")";
      labelColor = "rgba(" + color + ", " + labelOpacity + ")";
      _ref = this.findSpacing(), largeSpacing = _ref[0], smallSpacing = _ref[1];
      this.ctx.lineWidth = 1;
      this.ctx.strokeStyle = minorColor;
      _ref1 = ticks(smallSpacing, this.xMin, this.xMax);
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        x = _ref1[_i];
        drawLine(this.ctx, fromLocal([x, this.yMin]), fromLocal([x, this.yMax]));
      }
      _ref2 = ticks(smallSpacing, this.yMin, this.yMax);
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        y = _ref2[_j];
        drawLine(this.ctx, fromLocal([this.xMin, y]), fromLocal([this.xMax, y]));
      }
      this.ctx.strokeStyle = majorColor;
      _ref3 = ticks(largeSpacing, this.xMin, this.xMax);
      for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
        x = _ref3[_k];
        drawLine(this.ctx, fromLocal([x, this.yMin]), fromLocal([x, this.yMax]));
      }
      _ref4 = ticks(largeSpacing, this.yMin, this.yMax);
      for (_l = 0, _len3 = _ref4.length; _l < _len3; _l++) {
        y = _ref4[_l];
        drawLine(this.ctx, fromLocal([this.xMin, y]), fromLocal([this.xMax, y]));
      }
      this.ctx.strokeStyle = axesColor;
      drawLine(this.ctx, fromLocal([0, this.yMin]), fromLocal([0, this.yMax]));
      drawLine(this.ctx, fromLocal([this.xMin, 0]), fromLocal([this.xMax, 0]));
      this.ctx.font = "" + textHeight + "px verdana";
      this.ctx.fillStyle = labelColor;
      this.ctx.textAlign = "center";
      this.ctx.textBaseline = "top";
      _ref5 = ticks(largeSpacing, this.xMin, this.xMax);
      for (_m = 0, _len4 = _ref5.length; _m < _len4; _m++) {
        x = _ref5[_m];
        if (x !== 0) {
          text = parseFloat(x.toPrecision(12)).toString();
          _ref6 = fromLocal([x, 0]), cx = _ref6[0], cy = _ref6[1];
          cy += labelDistance;
          if (cy < labelDistance) {
            cy = labelDistance;
          }
          if (cy + textHeight + labelDistance > this.height()) {
            cy = this.height() - labelDistance - textHeight;
          }
          this.ctx.fillText(text, cx, cy);
        }
      }
      this.ctx.textAlign = "left";
      this.ctx.textBaseline = "middle";
      _ref7 = ticks(largeSpacing, this.yMin, this.yMax);
      for (_n = 0, _len5 = _ref7.length; _n < _len5; _n++) {
        y = _ref7[_n];
        if (y !== 0) {
          text = parseFloat(y.toPrecision(12)).toString();
          _ref8 = fromLocal([0, y]), cx = _ref8[0], cy = _ref8[1];
          cx += labelDistance;
          if (cx < labelDistance) {
            cx = labelDistance;
          }
          if (cx + this.ctx.measureText(text).width + labelDistance > this.width()) {
            cx = this.width() - labelDistance - this.ctx.measureText(text).width;
          }
          this.ctx.fillText(text, cx, cy);
        }
      }
      return this.ctx.restore();
    };

    Graph.prototype.drawGraph = function(fn, styleOpts) {
      var cx, cxMax, cxMin, cy, cyMax, cyMin, i, resolution, sizeX, sizeY, x, y, _i, _ref, _ref1, _ref2, _ref3;
      this.ctx.save();
      sizeX = this.xMax - this.xMin;
      sizeY = this.yMax - this.yMin;
      cxMin = 0;
      cxMax = this.width();
      cyMin = this.height();
      cyMax = 0;
      this.ctx.lineWidth = (_ref = styleOpts.lineWidth) != null ? _ref : 2;
      this.ctx.strokeStyle = (_ref1 = styleOpts.color) != null ? _ref1 : "#006";
      this.ctx.globalAlpha = (_ref2 = styleOpts.opacity) != null ? _ref2 : 1;
      this.ctx.beginPath();
      resolution = 1;
      for (i = _i = 0, _ref3 = this.width() / resolution; 0 <= _ref3 ? _i <= _ref3 : _i >= _ref3; i = 0 <= _ref3 ? ++_i : --_i) {
        cx = i * resolution;
        x = lerp(cx, cxMin, cxMax, this.xMin, this.xMax);
        y = fn(x);
        cy = lerp(y, this.yMin, this.yMax, cyMin, cyMax);
        this.ctx.lineTo(cx, cy);
      }
      this.ctx.stroke();
      return this.ctx.restore();
    };

    return Graph;

  })();

  GraphView = React.createClass({
    refreshGraph: function() {
      var canvas, data, graph, graphFn, rect, _i, _len, _ref, _results;
      canvas = this.getDOMNode();
      rect = canvas.getBoundingClientRect();
      canvas.width = rect.width;
      canvas.height = rect.height;
      graph = canvas.graph != null ? canvas.graph : canvas.graph = new Graph(canvas, -10, 10, -10, 10);
      graph.clear();
      _ref = this.props.drawData;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        data = _ref[_i];
        graphFn = function(xValue) {
          var env;
          env = editor.makeEnv(xValue);
          return data.apply.evaluate(env);
        };
        _results.push(graph.drawGraph(graphFn, data.styleOpts));
      }
      return _results;
    },
    componentDidMount: function() {
      return this.refreshGraph();
    },
    componentDidUpdate: function() {
      return this.refreshGraph();
    },
    render: function() {
      return d.canvas({});
    }
  });

  mainGraph = null;

  window.init = function() {
    var canvas;
    canvas = document.querySelector("#c");
    mainGraph = new Graph(canvas, -10, 10, -10, 10);
    window.addEventListener("resize", resize);
    window.addEventListener("pointermove", pointermove);
    window.addEventListener("pointerup", pointerup);
    canvas.addEventListener("pointerdown", pointerdown);
    return resize();
  };

  resize = function() {
    var canvas, rect;
    canvas = document.querySelector("#c");
    rect = canvas.getBoundingClientRect();
    canvas.width = rect.width;
    canvas.height = rect.height;
    return refresh();
  };

  refresh = function() {
    refreshView();
    mainGraph.clear();
    mainGraph.drawGrid();
    return editor.draw(mainGraph);
  };

  pointerdown = function(e) {
    e.preventDefault();
    document.activeElement.blur();
    return console.log(e);
  };

  updateHover = function(e) {
    var el, hoveredLinks, hoveredParams;
    el = e.target;
    hoveredLinks = [];
    hoveredParams = [];
    while (el.nodeType === Node.ELEMENT_NODE) {
      if (el.ssLink) {
        hoveredLinks.push(el.ssLink);
      }
      if (el.ssParam) {
        hoveredParams.push(el.ssParam);
      }
      el = el.parentNode;
    }
    if (!(_.isEqual(editor.hoveredLinks, hoveredLinks) && _.isEqual(editor.hoveredParams, hoveredParams))) {
      editor.hoveredLinks = hoveredLinks;
      editor.hoveredParams = hoveredParams;
      return refresh();
    }
  };

  pointermove = function(e) {
    if (pointerManager.isPointerCaptured(e)) {
      return;
    }
    return updateHover(e);
  };

  pointerup = function(e) {
    return updateHover(e);
  };

  Param = (function() {
    function Param(value) {
      this.value = value != null ? value : 0;
      this.id = _.uniqueId("p");
      this.title = "";
    }

    Param.prototype.evaluate = function(env) {
      var _ref;
      return (_ref = env.lookup(this)) != null ? _ref : this.value;
    };

    return Param;

  })();

  Env = (function() {
    function Env() {
      this.paramValues = {};
    }

    Env.prototype.set = function(param, value) {
      return this.paramValues[param.id] = value;
    };

    Env.prototype.lookup = function(param) {
      return this.paramValues[param.id];
    };

    return Env;

  })();

  Fn = (function() {
    function Fn(title, numParams, compute) {
      this.title = title;
      this.numParams = numParams;
      this.compute = compute;
    }

    return Fn;

  })();

  fnsToAdd = [
    new Fn("+", 2, function(a, b) {
      return a + b;
    }), new Fn("-", 2, function(a, b) {
      return a - b;
    }), new Fn("*", 2, function(a, b) {
      return a * b;
    }), new Fn("/", 2, function(a, b) {
      return a / b;
    }), new Fn("abs", 1, function(a) {
      return Math.abs(a);
    }), new Fn("sin", 1, function(a) {
      return Math.sin(a);
    }), new Fn("cos", 1, function(a) {
      return Math.cos(a);
    }), new Fn("fract", 1, function(a) {
      return a - Math.floor(a);
    }), new Fn("floor", 1, function(a) {
      return Math.floor(a);
    })
  ];

  Apply = (function() {
    function Apply(fn, params) {
      this.fn = fn;
      this.params = params;
    }

    Apply.prototype.evaluate = function(env) {
      var paramValues, _ref;
      paramValues = this.params.map(function(param) {
        return param.evaluate(env);
      });
      return (_ref = this.fn).compute.apply(_ref, paramValues);
    };

    return Apply;

  })();

  Chain = (function() {
    function Chain(startParam) {
      var startLink;
      startLink = new StartLink(startParam);
      this.links = [startLink];
    }

    Chain.prototype.appendLink = function(fn) {
      var additionalParams, link, _i, _ref, _results;
      additionalParams = (function() {
        _results = [];
        for (var _i = 0, _ref = fn.numParams - 1; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this).map(function() {
        return new Param();
      });
      link = new Link(fn, additionalParams);
      this.links.push(link);
      return link;
    };

    Chain.prototype.appendLinkAfter = function(fn, refLink) {
      var additionalParams, i, link, _i, _ref, _results;
      additionalParams = (function() {
        _results = [];
        for (var _i = 0, _ref = fn.numParams - 1; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this).map(function() {
        return new Param();
      });
      link = new Link(fn, additionalParams);
      i = this.links.indexOf(refLink);
      this.links.splice(i + 1, 0, link);
      return link;
    };

    return Chain;

  })();

  Link = (function() {
    function Link(fn, additionalParams) {
      this.fn = fn;
      this.additionalParams = additionalParams;
      this.addLinkVisible = false;
      this.id = _.uniqueId("l");
    }

    return Link;

  })();

  StartLink = (function() {
    function StartLink(startParam) {
      this.startParam = startParam;
    }

    return StartLink;

  })();

  Editor = (function() {
    function Editor() {
      this.params = [];
      this.chains = [];
      this.xParam = null;
      this.hoveredParams = [];
      this.hoveredLinks = [];
    }

    Editor.prototype.addParam = function() {
      var param;
      param = new Param();
      this.params.push(param);
      return param;
    };

    Editor.prototype.addChain = function(startParam) {
      var chain;
      chain = new Chain(startParam);
      this.chains.push(chain);
      return chain;
    };

    Editor.prototype.makeEnv = function(xValue) {
      var env;
      env = new Env();
      if (this.xParam) {
        env.set(this.xParam, xValue);
      }
      return env;
    };

    Editor.prototype.draw = function(graph) {
      var chain, link, param, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _results;
      _ref = this.chains;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        chain = _ref[_i];
        link = _.last(chain.links);
        this.drawChainLinkResult(graph, chain, link, {
          color: "#000",
          opacity: 1
        });
      }
      _ref1 = this.hoveredLinks;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        link = _ref1[_j];
        this.drawChainLink(graph, chain, link, {
          color: "#900",
          opacity: 0.5
        });
      }
      _ref2 = this.hoveredParams;
      _results = [];
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        param = _ref2[_k];
        _results.push(this.drawParam(graph, param, {
          color: "green"
        }));
      }
      return _results;
    };

    Editor.prototype.drawParam = function(graph, param, styleOpts) {
      var graphFn,
        _this = this;
      graphFn = function(xValue) {
        var env;
        env = _this.makeEnv(xValue);
        return param.evaluate(env);
      };
      return graph.drawGraph(graphFn, styleOpts);
    };

    Editor.prototype.drawChainLinkResult = function(graph, chain, link, styleOpts) {
      var apply, graphFn,
        _this = this;
      apply = this.applyForChainLink(chain, link);
      graphFn = function(xValue) {
        var env;
        env = _this.makeEnv(xValue);
        return apply.evaluate(env);
      };
      return graph.drawGraph(graphFn, styleOpts);
    };

    Editor.prototype.drawChainLink = function(graph, chain, link) {
      var apply, graphFn, param, styleOpts, _i, _len, _ref,
        _this = this;
      apply = this.applyForChainLink(chain, link);
      if (apply.params) {
        _ref = apply.params;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          param = _ref[_i];
          graphFn = function(xValue) {
            var env;
            env = _this.makeEnv(xValue);
            return param.evaluate(env);
          };
          if (param instanceof Param && param !== this.xParam) {
            styleOpts = {
              color: "green",
              opacity: 0.4
            };
          } else {
            styleOpts = {
              color: "#000",
              opacity: 0.1
            };
          }
          graph.drawGraph(graphFn, styleOpts);
        }
      }
      styleOpts = {
        color: "#900"
      };
      graphFn = function(xValue) {
        var env;
        env = _this.makeEnv(xValue);
        return apply.evaluate(env);
      };
      return graph.drawGraph(graphFn, styleOpts);
    };

    Editor.prototype.applyForChainLink = function(chain, link) {
      var apply, l, params, _i, _len, _ref;
      _ref = chain.links;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        l = _ref[_i];
        if (l instanceof StartLink) {
          apply = l.startParam;
        } else {
          params = [apply].concat(l.additionalParams);
          apply = new Apply(l.fn, params);
        }
        if (l === link) {
          break;
        }
      }
      return apply;
    };

    return Editor;

  })();

  editor = new Editor();

  (function() {
    var a, chain;
    a = new Param();
    editor.xParam = a;
    return chain = editor.addChain(a);
  })();

  PointerManager = (function() {
    function PointerManager() {
      this.handleUp = __bind(this.handleUp, this);
      this.handleMove = __bind(this.handleMove, this);
      this.capturedPointers = {};
      window.addEventListener("pointermove", this.handleMove);
      window.addEventListener("pointerup", this.handleUp);
    }

    PointerManager.prototype.pointerId = function(e) {
      var _ref;
      return (_ref = e.pointerId) != null ? _ref : 1;
    };

    PointerManager.prototype.isPointerCaptured = function(e) {
      var pointerId;
      pointerId = this.pointerId(e);
      return this.capturedPointers[pointerId];
    };

    PointerManager.prototype.capture = function(e, handleMove, handleUp) {
      var pointerId;
      pointerId = this.pointerId(e);
      return this.capturedPointers[pointerId] = {
        handleMove: handleMove,
        handleUp: handleUp
      };
    };

    PointerManager.prototype.uncapture = function(e) {
      var pointerId;
      pointerId = this.pointerId(e);
      return delete this.capturedPointers[pointerId];
    };

    PointerManager.prototype.handleMove = function(e) {
      var captured;
      captured = this.isPointerCaptured(e);
      if (captured) {
        return typeof captured.handleMove === "function" ? captured.handleMove(e) : void 0;
      }
    };

    PointerManager.prototype.handleUp = function(e) {
      var captured;
      captured = this.isPointerCaptured(e);
      if (captured) {
        this.uncapture(e);
        return typeof captured.handleUp === "function" ? captured.handleUp(e) : void 0;
      }
    };

    return PointerManager;

  })();

  pointerManager = new PointerManager();

  lerp = function(x, dMin, dMax, rMin, rMax) {
    var ratio;
    ratio = (x - dMin) / (dMax - dMin);
    return ratio * (rMax - rMin) + rMin;
  };

  compose = function(f, g) {
    return function(x) {
      return f(g(x));
    };
  };

  if ((_base = Element.prototype).matches == null) {
    _base.matches = (_ref = (_ref1 = Element.prototype.webkitMatchesSelector) != null ? _ref1 : Element.prototype.mozMatchesSelector) != null ? _ref : Element.prototype.oMatchesSelector;
  }

  Element.prototype.closest = function(selector) {
    var fn, parent;
    if (_.isString(selector)) {
      fn = function(el) {
        return el.matches(selector);
      };
    } else {
      fn = selector;
    }
    if (fn(this)) {
      return this;
    } else {
      parent = this.parentNode;
      if ((parent != null) && parent.nodeType === Node.ELEMENT_NODE) {
        return parent.closest(fn);
      } else {
        return void 0;
      }
    }
  };

  d = React.DOM;

  cx = React.addons.classSet;

  refreshView = (function() {
    var AddLinkView, ChainView, EditorView, LinkView, ParamTitleView, ParamValueView, ParamView, setAdd, setRemove, truncate;
    truncate = function(value) {
      var decimalPlace, s;
      s = "" + value;
      decimalPlace = s.indexOf(".");
      if (decimalPlace) {
        return s.substr(0, decimalPlace + 4);
      }
    };
    setAdd = function(list, value) {
      if (list.indexOf(value) === -1) {
        return list.push(value);
      }
    };
    setRemove = function(list, value) {
      var i;
      if ((i = list.indexOf(value)) !== -1) {
        return list.splice(i, 1);
      }
    };
    ParamValueView = React.createClass({
      handleMouseDown: function(e) {
        var originalValue, originalY, param;
        param = this.props.param;
        e.preventDefault();
        originalY = e.clientY;
        originalValue = param.value;
        return pointerManager.capture(e, function(e) {
          var dy, multiplier;
          dy = e.clientY - originalY;
          multiplier = -(mainGraph.yMax - mainGraph.yMin) / mainGraph.height();
          param.value = originalValue + dy * multiplier;
          return refresh();
        });
      },
      render: function() {
        var param,
          _this = this;
        param = this.props.param;
        return d.span({
          className: "paramValue",
          onMouseDown: this.handleMouseDown
        }, (function() {
          if (editor.xParam === param) {
            return d.i({}, "x");
          } else {
            return truncate(param.value);
          }
        })());
      }
    });
    ParamTitleView = React.createClass({
      handleMouseDown: function(e) {
        var el, ghost, moveGhost, originalGhostX, originalGhostY, originalX, originalY, rect;
        el = this.getDOMNode();
        if (el === document.activeElement) {
          return;
        }
        e.preventDefault();
        el = el.closest(".param");
        originalX = e.clientX;
        originalY = e.clientY;
        rect = el.getBoundingClientRect();
        originalGhostX = rect.left;
        originalGhostY = rect.top;
        ghost = el.cloneNode(true);
        ghost.style.position = "absolute";
        ghost.style.opacity = "0.5";
        ghost.style.pointerEvents = "none";
        document.body.appendChild(ghost);
        moveGhost = function(x, y) {
          ghost.style.top = y + "px";
          return ghost.style.left = x + "px";
        };
        moveGhost(originalGhostX, originalGhostY);
        editor.movingParam = this.props.param;
        return pointerManager.capture(e, function(e) {
          var dx, dy;
          dx = e.clientX - originalX;
          dy = e.clientY - originalY;
          return moveGhost(originalGhostX + dx, originalGhostY + dy);
        }, function(e) {
          document.body.removeChild(ghost);
          return setTimeout((function() {
            return editor.movingParam = null;
          }), 1);
        });
      },
      handleInput: function() {
        var el, newTitle;
        el = this.getDOMNode();
        newTitle = el.textContent;
        if (el.innerHTML !== newTitle) {
          el.innerHTML = newTitle;
        }
        this.props.param.title = newTitle;
        return refresh();
      },
      handleDoubleClick: function() {
        var el;
        el = this.getDOMNode();
        return el.focus();
      },
      render: function() {
        var param;
        param = this.props.param;
        return d.span({
          className: "paramTitle",
          contentEditable: true,
          onMouseDown: this.handleMouseDown,
          onDoubleClick: this.handleDoubleClick,
          onInput: this.handleInput
        }, param.title);
      }
    });
    ParamView = React.createClass({
      componentDidMount: function() {
        return this.getDOMNode().ssParam = this.props.param;
      },
      handleMouseUp: function(e) {
        if (!editor.movingParam) {
          return;
        }
        return this.props.replaceSelf(editor.movingParam);
      },
      render: function() {
        var classNames;
        classNames = cx({
          param: true,
          hovered: _.contains(editor.hoveredParams, this.props.param)
        });
        return d.div({
          className: classNames,
          onMouseUp: this.handleMouseUp
        }, ParamTitleView({
          param: this.props.param
        }), ParamValueView({
          param: this.props.param
        }));
      }
    });
    ChainView = React.createClass({
      render: function() {
        var chain;
        chain = this.props.chain;
        return d.div({
          className: "chain"
        }, d.div({
          className: "links"
        }, chain.links.map(function(link) {
          return LinkView({
            link: link,
            chain: chain,
            key: link.id
          });
        })));
      }
    });
    AddLinkView = React.createClass({
      handleClickOn: function(fn) {
        var _this = this;
        return function() {
          var chain, link, newLink, _ref2;
          _ref2 = _this.props, chain = _ref2.chain, link = _ref2.link;
          newLink = chain.appendLinkAfter(fn, link);
          link.addLinkVisible = false;
          return refresh();
        };
      },
      render: function() {
        var _this = this;
        return d.div({
          className: "addLink"
        }, fnsToAdd.map(function(fn) {
          return d.div({
            className: "row",
            onClick: _this.handleClickOn(fn)
          }, fn.title);
        }));
      }
    });
    LinkView = React.createClass({
      toggleAddLink: function() {
        var chain, link, _ref2;
        _ref2 = this.props, chain = _ref2.chain, link = _ref2.link;
        link.addLinkVisible = !link.addLinkVisible;
        return refresh();
      },
      componentDidMount: function() {
        var chain, link, thumbEl, _ref2;
        _ref2 = this.props, chain = _ref2.chain, link = _ref2.link;
        thumbEl = this.refs.thumb.getDOMNode();
        return thumbEl.ssLink = link;
      },
      renderThumbnail: function() {
        var apply, drawData, param, styleOpts, _i, _len, _ref2;
        drawData = [];
        apply = editor.applyForChainLink(this.props.chain, this.props.link);
        if (apply.params) {
          _ref2 = apply.params;
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            param = _ref2[_i];
            if (param instanceof Param && param !== editor.xParam) {
              styleOpts = {
                color: "green",
                opacity: 0.4
              };
            } else {
              styleOpts = {
                color: "#000",
                opacity: 0.1
              };
            }
            drawData.push({
              apply: param,
              styleOpts: styleOpts
            });
          }
        }
        drawData.push({
          apply: apply,
          styleOpts: {
            color: "#000"
          }
        });
        return GraphView({
          drawData: drawData
        });
      },
      render: function() {
        var chain, classNames, link, _ref2;
        _ref2 = this.props, chain = _ref2.chain, link = _ref2.link;
        classNames = cx({
          link: true,
          row: true,
          hovered: _.contains(editor.hoveredLinks, link)
        });
        return d.div({}, d.div({
          className: classNames
        }, d.div({
          className: "tinyGraph",
          style: {
            float: "right",
            margin: -7
          },
          ref: "thumb"
        }, this.renderThumbnail()), link instanceof StartLink ? ParamView({
          param: link.startParam,
          replaceSelf: function(p) {
            link.startParam = p;
            return refresh();
          }
        }) : d.span({}, d.span({
          className: "linkTitle",
          style: {
            marginRight: 6
          }
        }, link.fn.title), link.additionalParams.map(function(param, i) {
          return ParamView({
            param: param,
            key: "" + i + "/" + param.id,
            replaceSelf: function(p) {
              link.additionalParams[i] = p;
              return refresh();
            }
          });
        })), d.button({
          className: "addLinkButton",
          onClick: this.toggleAddLink
        }, "+")), link.addLinkVisible ? AddLinkView({
          chain: chain,
          link: link
        }) : void 0);
      }
    });
    EditorView = React.createClass({
      render: function() {
        return d.div({
          className: "editor"
        }, editor.chains.map(function(chain) {
          return ChainView({
            chain: chain
          });
        }));
      }
    });
    return function() {
      var manager;
      manager = document.querySelector("#manager");
      return React.renderComponent(EditorView(), manager);
    };
  })();

}).call(this);
