
(function(/*! Stitch !*/) {
  if (!this.require) {
    var modules = {}, cache = {}, require = function(name, root) {
      var path = expand(root, name), module = cache[path], fn;
      if (module) {
        return module.exports;
      } else if (fn = modules[path] || modules[path = expand(path, './index')]) {
        module = {id: path, exports: {}};
        try {
          cache[path] = module;
          fn(module.exports, function(name) {
            return require(name, dirname(path));
          }, module);
          return module.exports;
        } catch (err) {
          delete cache[path];
          throw err;
        }
      } else {
        throw 'module \'' + name + '\' not found';
      }
    }, expand = function(root, name) {
      var results = [], parts, part;
      if (/^\.\.?(\/|$)/.test(name)) {
        parts = [root, name].join('/').split('/');
      } else {
        parts = name.split('/');
      }
      for (var i = 0, length = parts.length; i < length; i++) {
        part = parts[i];
        if (part == '..') {
          results.pop();
        } else if (part != '.' && part != '') {
          results.push(part);
        }
      }
      return results.join('/');
    }, dirname = function(path) {
      return path.split('/').slice(0, -1).join('/');
    };
    this.require = function(name) {
      return require(name, '');
    }
    this.require.define = function(bundle) {
      for (var key in bundle)
        modules[key] = bundle[key];
    };
  }
  return this.require.define;
}).call(this)({"config": function(exports, require, module) {(function() {
  var config;

  module.exports = window.config = config = {
    minGridSpacing: 70,
    hitTolerance: 15,
    snapTolerance: 5,
    resolution: 0.5,
    spreadOpacityMax: 0.2,
    spreadOpacityMin: 0.02,
    shaderOpacity: 1,
    gridColor: "210,200,170",
    styles: {
      "default": {
        strokeStyle: "#000",
        globalAlpha: 1,
        lineWidth: 2
      },
      param: {
        strokeStyle: "green",
        globalAlpha: 0.4
      },
      hoveredParam: {
        strokeStyle: "green",
        globalAlpha: 1
      },
      apply: {
        strokeStyle: "#000",
        globalAlpha: 0.1
      },
      hoveredApply: {
        strokeStyle: "#900"
      },
      resultApply: {
        strokeStyle: "#000"
      },
      spreadPositive: {
        strokeStyle: "#900"
      },
      spreadNegative: {
        strokeStyle: "#009"
      }
    }
  };

}).call(this);
}, "editor": function(exports, require, module) {(function() {
  var Apply, Block, Editor, Param, Persistence, builtInFns, editor, startApply;

  require("./model/register");

  Persistence = require("./persistence/Persistence");

  Editor = require("./model/Editor");

  Block = require("./model/Block");

  Apply = require("./model/Apply");

  Param = require("./model/Param");

  builtInFns = require("./model/builtInFns");

  editor = Persistence.loadState();

  if (!editor) {
    editor = new Editor();
    editor.rootBlock = new Block();
    startApply = new Apply(builtInFns[0]);
    editor.rootBlock.root = startApply;
  }

  window.editor = editor;

  module.exports = editor;

}).call(this);
}, "main": function(exports, require, module) {(function() {
  var EditorView, Persistence, editor, eventName, handleWindowMouseMove, handleWindowMouseUp, refresh, refreshView, willRefreshNextFrame, _i, _len, _ref;

  require("./util/domAddons");

  editor = require("./editor");

  Persistence = require("./persistence/Persistence");

  EditorView = require("./view/EditorView");

  window.reset = function() {
    Persistence.reset();
    return location.reload();
  };

  willRefreshNextFrame = false;

  refresh = function() {
    if (willRefreshNextFrame) {
      return;
    }
    willRefreshNextFrame = true;
    return requestAnimationFrame(function() {
      refreshView();
      Persistence.saveState(editor);
      return willRefreshNextFrame = false;
    });
  };

  refreshView = function() {
    var editorEl;
    editorEl = document.querySelector("#editor");
    return React.renderComponent(EditorView(), editorEl);
  };

  handleWindowMouseMove = function(e) {
    var _ref;
    editor.mousePosition = {
      x: e.clientX,
      y: e.clientY
    };
    return (_ref = editor.dragging) != null ? typeof _ref.onMove === "function" ? _ref.onMove(e) : void 0 : void 0;
  };

  handleWindowMouseUp = function(e) {
    var _ref;
    if ((_ref = editor.dragging) != null) {
      if (typeof _ref.onUp === "function") {
        _ref.onUp(e);
      }
    }
    return editor.dragging = null;
  };

  window.addEventListener("mousemove", handleWindowMouseMove);

  window.addEventListener("mouseup", handleWindowMouseUp);

  _ref = ["mousedown", "mousemove", "mouseup", "keydown", "scroll", "change"];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    eventName = _ref[_i];
    window.addEventListener(eventName, refresh);
  }

  refresh();

}).call(this);
}, "model/Apply": function(exports, require, module) {(function() {
  var Apply, ObjectManager, Param, builtInFns;

  ObjectManager = require("../persistence/ObjectManager");

  Param = require("./Param");

  builtInFns = require("./builtInFns");

  module.exports = Apply = (function() {
    function Apply(fn) {
      this.fn = fn;
      ObjectManager.assignId(this);
      this.params = [];
      if (this.fn) {
        this.initializeDefaultParams();
      }
    }

    Apply.prototype.headParam = function() {
      return this.params[0];
    };

    Apply.prototype.tailParams = function() {
      return _.tail(this.params);
    };

    Apply.prototype.allParams = function() {
      return this.params;
    };

    Apply.prototype.initializeDefaultParams = function() {
      return this.params = this.fn.defaultParams.map(function(paramValue) {
        var param;
        if (paramValue != null) {
          return param = new Param(paramValue);
        } else {
          return param = null;
        }
      });
    };

    Apply.prototype.setParam = function(index, param) {
      return this.params[index] = param;
    };

    Apply.prototype.compileString = function() {
      var paramCompileStrings, _ref;
      paramCompileStrings = this.params.map(function(param) {
        return param != null ? param.compileString() : void 0;
      });
      return (_ref = this.fn).compileString.apply(_ref, paramCompileStrings);
    };

    Apply.prototype.compileGlslString = function() {
      var paramCompileStrings, _ref;
      paramCompileStrings = this.params.map(function(param) {
        return param != null ? param.compileGlslString() : void 0;
      });
      return (_ref = this.fn).compileGlslString.apply(_ref, paramCompileStrings);
    };

    Apply.prototype.isStart = function() {
      return this.fn === builtInFns.constantFn;
    };

    return Apply;

  })();

}).call(this);
}, "model/Block": function(exports, require, module) {(function() {
  var Block, ObjectManager, ProvisionalApply;

  ObjectManager = require("../persistence/ObjectManager");

  ProvisionalApply = require("./ProvisionalApply");

  module.exports = Block = (function() {
    function Block() {
      ObjectManager.assignId(this);
      this.root = null;
    }

    Block.prototype.applies = function() {
      var applies, apply;
      applies = [];
      apply = this.root;
      while (apply != null) {
        applies.unshift(apply);
        apply = apply.params[0];
      }
      return applies;
    };

    Block.prototype.nextApply = function(refApply) {
      var nextApply;
      nextApply = this.root;
      while (nextApply && nextApply.params[0] !== refApply) {
        nextApply = nextApply.params[0];
      }
      return nextApply;
    };

    Block.prototype.removeApply = function(apply) {
      var nextApply;
      if (this.root === apply) {
        return this.root = apply.params[0];
      } else {
        nextApply = this.nextApply(apply);
        if (nextApply) {
          return nextApply.setParam(0, apply.params[0]);
        }
      }
    };

    Block.prototype.insertApplyAfter = function(apply, refApply) {
      var nextApply;
      if (this.root === refApply) {
        this.root = apply;
        return apply.setParam(0, refApply);
      } else {
        nextApply = this.nextApply(refApply);
        if (nextApply) {
          nextApply.setParam(0, apply);
          return apply.setParam(0, refApply);
        }
      }
    };

    Block.prototype.insertNewApplyAfter = function(refApply) {
      var apply;
      apply = new ProvisionalApply();
      return this.insertApplyAfter(apply, refApply);
    };

    Block.prototype.replaceApply = function(apply, refApply) {
      this.insertApplyAfter(apply, refApply);
      return this.removeApply(refApply);
    };

    return Block;

  })();

}).call(this);
}, "model/Editor": function(exports, require, module) {(function() {
  var Editor, Param, ProvisionalApply;

  Param = require("./Param");

  ProvisionalApply = require("./ProvisionalApply");

  module.exports = Editor = (function() {
    function Editor() {
      this.rootBlock = null;
      this.xParam = null;
      this.yParam = null;
      this.hoveredParam = null;
      this.hoveredApply = null;
      this.selectedBlock = null;
      this.selectedApply1 = null;
      this.selectedApply2 = null;
      this.cursor = null;
      this.mousePosition = {
        x: 0,
        y: 0
      };
      this.dragging = null;
      this.outputSwitch = "Cartesian";
      this.shaderView = false;
      this.contourView = false;
    }

    Editor.prototype.spreadParam = function() {
      if (this.dragging) {
        return null;
      }
      if (this.hoveredParam === this.xParam || this.hoveredParam === this.yParam) {
        return null;
      }
      return this.hoveredParam;
    };

    Editor.prototype.isApplySelected = function(block, apply) {
      var applies, index1, index2, refIndex;
      if (this.selectedBlock !== block) {
        return false;
      }
      if ((this.selectedApply1 != null) && (this.selectedApply2 != null)) {
        applies = block.applies();
        refIndex = applies.indexOf(apply);
        index1 = applies.indexOf(this.selectedApply1);
        index2 = applies.indexOf(this.selectedApply2);
        return (Math.min(index1, index2) <= refIndex && refIndex <= Math.max(index1, index2));
      } else if (this.selectedApply1 != null) {
        return apply === this.selectedApply1;
      } else {
        return false;
      }
    };

    Editor.prototype.unsetSelection = function() {
      this.selectedBlock = null;
      this.selectedApply1 = null;
      return this.selectedApply2 = null;
    };

    Editor.prototype.setSingleSelection = function(block, apply) {
      this.selectedBlock = block;
      this.selectedApply1 = apply;
      return this.selectedApply2 = null;
    };

    Editor.prototype.setRangeSelection = function(block, apply) {
      if (this.selectedApply1 && this.selectedBlock === block) {
        return this.selectedApply2 = apply;
      } else {
        return this.setSingleSelection(block, apply);
      }
    };

    return Editor;

  })();

}).call(this);
}, "model/Fn": function(exports, require, module) {(function() {
  var Fn, ObjectManager;

  ObjectManager = require("../persistence/ObjectManager");

  module.exports = Fn = (function() {
    function Fn(title, defaultParams, compileString, compileGlslString) {
      this.title = title;
      this.defaultParams = defaultParams;
      this.compileString = compileString;
      this.compileGlslString = compileGlslString;
      ObjectManager.registerBuiltInObject("fn-" + this.title, this);
    }

    return Fn;

  })();

}).call(this);
}, "model/Param": function(exports, require, module) {(function() {
  var ObjectManager, Param;

  ObjectManager = require("../persistence/ObjectManager");

  module.exports = Param = (function() {
    function Param(value) {
      this.value = value != null ? value : 0;
      ObjectManager.assignId(this);
      this.title = "";
      this.axis = "result";
    }

    Param.prototype.compileString = function() {
      var editor;
      editor = require("../editor");
      if (this === editor.xParam) {
        return "x";
      } else if (this === editor.spreadParam()) {
        return "(" + this.value + " + spreadOffset)";
      } else {
        return "" + this.value;
      }
    };

    Param.prototype.compileGlslString = function() {
      var editor, floatString;
      editor = require("../editor");
      if (this === editor.xParam) {
        return "x";
      } else if (this === editor.yParam) {
        return "y";
      } else {
        floatString = "" + this.value;
        if (floatString.indexOf(".") === -1) {
          floatString += ".";
        }
        return floatString;
      }
    };

    return Param;

  })();

}).call(this);
}, "model/ProvisionalApply": function(exports, require, module) {(function() {
  var Apply, ObjectManager, ProvisionalApply, builtInFns,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ObjectManager = require("../persistence/ObjectManager");

  Apply = require("./Apply");

  builtInFns = require("./builtInFns");

  module.exports = ProvisionalApply = (function(_super) {
    __extends(ProvisionalApply, _super);

    function ProvisionalApply() {
      ObjectManager.assignId(this);
      this.params = [null];
      this.possibleApplies = builtInFns.map(function(fn) {
        return new Apply(fn);
      });
      this.stagedApply = null;
    }

    ProvisionalApply.prototype.setParam = function(index, param) {
      var possibleApply, _i, _len, _ref, _results;
      this.params[index] = param;
      _ref = this.possibleApplies;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        possibleApply = _ref[_i];
        _results.push(possibleApply.setParam(index, param));
      }
      return _results;
    };

    ProvisionalApply.prototype.effectiveApply = function() {
      var _ref;
      return (_ref = this.stagedApply) != null ? _ref : this.params[0];
    };

    ProvisionalApply.prototype.compileString = function() {
      return this.effectiveApply().compileString();
    };

    ProvisionalApply.prototype.compileGlslString = function() {
      return this.effectiveApply().compileGlslString();
    };

    return ProvisionalApply;

  })(Apply);

}).call(this);
}, "model/builtInFns": function(exports, require, module) {(function() {
  var Fn, builtInFns, constantFn, identityFn;

  Fn = require("./Fn");

  constantFn = new Fn("", [null, 0], function(a, b) {
    return "" + b;
  }, function(a, b) {
    return "" + b;
  });

  identityFn = new Fn("identity", [0], function(a) {
    return "" + a;
  }, function(a) {
    return "" + a;
  });

  builtInFns = [
    constantFn, new Fn("+", [0, 0], function(a, b) {
      return "(" + a + " + " + b + ")";
    }, function(a, b) {
      return "(" + a + " + " + b + ")";
    }), new Fn("-", [0, 0], function(a, b) {
      return "(" + a + " - " + b + ")";
    }, function(a, b) {
      return "(" + a + " - " + b + ")";
    }), new Fn("*", [1, 1], function(a, b) {
      return "(" + a + " * " + b + ")";
    }, function(a, b) {
      return "(" + a + " * " + b + ")";
    }), new Fn("/", [1, 1], function(a, b) {
      return "(" + a + " / " + b + ")";
    }, function(a, b) {
      return "(" + a + " / " + b + ")";
    }), new Fn("abs", [0], function(a) {
      return "Math.abs(" + a + ")";
    }, function(a) {
      return "abs(" + a + ")";
    }), new Fn("sqrt", [0], function(a) {
      return "Math.sqrt(" + a + ")";
    }, function(a) {
      return "sqrt(" + a + ")";
    }), new Fn("pow", [1, 1], function(a, b) {
      return "Math.pow(Math.abs(" + a + "), " + b + ")";
    }, function(a, b) {
      return "pow(" + a + ", " + b + ")";
    }), new Fn("sin", [0], function(a) {
      return "Math.sin(" + a + ")";
    }, function(a) {
      return "sin(" + a + ")";
    }), new Fn("cos", [0], function(a) {
      return "Math.cos(" + a + ")";
    }, function(a) {
      return "cos(" + a + ")";
    }), new Fn("fract", [0], function(a) {
      return "(" + a + " - Math.floor(" + a + "))";
    }, function(a) {
      return "fract(" + a + ")";
    }), new Fn("floor", [0], function(a) {
      return "Math.floor(" + a + ")";
    }, function(a) {
      return "floor(" + a + ")";
    }), new Fn("ceil", [0], function(a) {
      return "Math.ceil(" + a + ")";
    }, function(a) {
      return "ceil(" + a + ")";
    }), new Fn("min", [0, 0], function(a, b) {
      return "Math.min(" + a + ", " + b + ")";
    }, function(a, b) {
      return "min(" + a + ", " + b + ")";
    }), new Fn("max", [0, 0], function(a, b) {
      return "Math.max(" + a + ", " + b + ")";
    }, function(a, b) {
      return "max(" + a + ", " + b + ")";
    })
  ];

  builtInFns.constantFn = constantFn;

  builtInFns.identityFn = identityFn;

  module.exports = builtInFns;

}).call(this);
}, "model/register": function(exports, require, module) {(function() {
  var Apply, Block, Editor, ObjectManager, Param, ProvisionalApply;

  ObjectManager = require("../persistence/ObjectManager");

  Param = require("model/Param");

  Apply = require("model/Apply");

  ProvisionalApply = require("model/ProvisionalApply");

  Block = require("model/Block");

  Editor = require("model/Editor");

  ObjectManager.registerClass("Param", Param);

  ObjectManager.registerClass("Apply", Apply);

  ObjectManager.registerClass("ProvisionalApply", ProvisionalApply);

  ObjectManager.registerClass("Block", Block);

  ObjectManager.registerClass("Editor", Editor);

  require("./builtInFns");

}).call(this);
}, "persistence/ObjectManager": function(exports, require, module) {(function() {
  var ObjectManager,
    __hasProp = {}.hasOwnProperty;

  module.exports = ObjectManager = new ((function() {
    function _Class() {
      this.idCounter_ = 0;
      this.classNames_ = {};
      this.builtInObjects_ = {};
    }

    _Class.prototype.assignId = function(object) {
      var id;
      this.idCounter_++;
      id = "id-" + this.idCounter_ + Date.now() + Math.floor(1e9 * Math.random());
      return object.__id = id;
    };

    _Class.prototype.registerClass = function(className, classConstructor) {
      this.classNames_[className] = classConstructor;
      return classConstructor.prototype.__className = className;
    };

    _Class.prototype.registerBuiltInObject = function(id, object) {
      this.builtInObjects_[id] = object;
      return object.__id = id;
    };

    _Class.prototype.deconstruct = function(object) {
      var objects, root, serialize;
      objects = {};
      serialize = (function(_this) {
        return function(object, force) {
          var entry, id, key, result, value, _i, _len;
          if (force == null) {
            force = false;
          }
          if (!force && (id = object != null ? object.__id : void 0)) {
            if (!_this.builtInObjects_[id] && !objects[id]) {
              objects[id] = serialize(object, true);
            }
            return {
              __ref: id
            };
          }
          if (_.isArray(object)) {
            result = [];
            for (_i = 0, _len = object.length; _i < _len; _i++) {
              entry = object[_i];
              result.push(serialize(entry));
            }
            return result;
          }
          if (_.isObject(object)) {
            result = {};
            for (key in object) {
              if (!__hasProp.call(object, key)) continue;
              value = object[key];
              result[key] = serialize(value);
            }
            if (object.__className) {
              result.__className = object.__className;
            }
            return result;
          }
          return object != null ? object : null;
        };
      })(this);
      root = serialize(object);
      return {
        objects: objects,
        root: root
      };
    };

    _Class.prototype.reconstruct = function(_arg) {
      var constructObject, constructedObjects, derefObject, id, object, objects, root;
      objects = _arg.objects, root = _arg.root;
      constructedObjects = {};
      constructObject = (function(_this) {
        return function(object) {
          var classConstructor, className, constructedObject, key, value;
          if (className = object.__className) {
            classConstructor = _this.classNames_[className];
            constructedObject = new classConstructor();
            for (key in object) {
              if (!__hasProp.call(object, key)) continue;
              value = object[key];
              if (key !== "__className") {
                constructedObject[key] = value;
              }
            }
            return constructedObject;
          }
          return object;
        };
      })(this);
      for (id in objects) {
        if (!__hasProp.call(objects, id)) continue;
        object = objects[id];
        constructedObjects[id] = constructObject(object);
      }
      root = constructObject(root);
      derefObject = (function(_this) {
        return function(object) {
          var key, value, _ref, _results;
          if (!_.isObject(object)) {
            return;
          }
          _results = [];
          for (key in object) {
            if (!__hasProp.call(object, key)) continue;
            value = object[key];
            if (id = value != null ? value.__ref : void 0) {
              _results.push(object[key] = (_ref = _this.builtInObjects_[id]) != null ? _ref : constructedObjects[id]);
            } else {
              _results.push(derefObject(value));
            }
          }
          return _results;
        };
      })(this);
      for (id in constructedObjects) {
        if (!__hasProp.call(constructedObjects, id)) continue;
        object = constructedObjects[id];
        derefObject(object);
      }
      derefObject(root);
      return root;
    };

    return _Class;

  })());

}).call(this);
}, "persistence/Persistence": function(exports, require, module) {(function() {
  var ObjectManager, Persistence;

  ObjectManager = require("./ObjectManager");

  module.exports = Persistence = new ((function() {
    function _Class() {}

    _Class.prototype.saveState = function(editor) {
      var deconstructed, deconstructedString;
      deconstructed = ObjectManager.deconstruct(editor);
      deconstructedString = JSON.stringify(deconstructed);
      return window.localStorage.spaceShader = deconstructedString;
    };

    _Class.prototype.loadState = function() {
      var deconstructed, deconstructedString, editor;
      deconstructedString = window.localStorage.spaceShader;
      if (!deconstructedString) {
        return null;
      } else {
        editor = null;
        try {
          deconstructed = JSON.parse(deconstructedString);
          editor = ObjectManager.reconstruct(deconstructed);
        } catch (_error) {}
        return editor;
      }
    };

    _Class.prototype.reset = function() {
      return delete window.localStorage.spaceShader;
    };

    return _Class;

  })());

}).call(this);
}, "util/domAddons": function(exports, require, module) {(function() {
  var _base, _ref, _ref1;

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

  Element.prototype.getMarginRect = function() {
    var rect, result, style;
    rect = this.getBoundingClientRect();
    style = window.getComputedStyle(this);
    result = {
      top: rect.top - parseInt(style["margin-top"], 10),
      left: rect.left - parseInt(style["margin-left"], 10),
      bottom: rect.bottom + parseInt(style["margin-bottom"], 10),
      right: rect.right + parseInt(style["margin-right"], 10)
    };
    result.width = result.right - result.left;
    result.height = result.bottom - result.top;
    return result;
  };

  
// http://paulirish.com/2011/requestanimationframe-for-smart-animating/
// http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating

// requestAnimationFrame polyfill by Erik Möller. fixes from Paul Irish and Tino Zijdel

// MIT license

(function() {
    var lastTime = 0;
    var vendors = ['ms', 'moz', 'webkit', 'o'];
    for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
        window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
        window.cancelAnimationFrame = window[vendors[x]+'CancelAnimationFrame']
                                   || window[vendors[x]+'CancelRequestAnimationFrame'];
    }

    if (!window.requestAnimationFrame)
        window.requestAnimationFrame = function(callback, element) {
            var currTime = new Date().getTime();
            var timeToCall = Math.max(0, 16 - (currTime - lastTime));
            var id = window.setTimeout(function() { callback(currTime + timeToCall); },
              timeToCall);
            lastTime = currTime + timeToCall;
            return id;
        };

    if (!window.cancelAnimationFrame)
        window.cancelAnimationFrame = function(id) {
            clearTimeout(id);
        };
}());
;

}).call(this);
}, "util/lerp": function(exports, require, module) {(function() {
  var lerp;

  module.exports = lerp = function(x, dMin, dMax, rMin, rMax) {
    var ratio;
    ratio = (x - dMin) / (dMax - dMin);
    return ratio * (rMax - rMin) + rMin;
  };

}).call(this);
}, "util/onceDragConsummated": function(exports, require, module) {(function() {
  var onceDragConsummated;

  module.exports = onceDragConsummated = function(downEvent, callback, notConsummatedCallback) {
    var consummated, handleMove, handleUp, originalX, originalY, removeListeners;
    if (notConsummatedCallback == null) {
      notConsummatedCallback = null;
    }
    consummated = false;
    originalX = downEvent.clientX;
    originalY = downEvent.clientY;
    handleMove = function(moveEvent) {
      var d, dx, dy;
      dx = moveEvent.clientX - originalX;
      dy = moveEvent.clientY - originalY;
      d = Math.max(Math.abs(dx), Math.abs(dy));
      if (d > 3) {
        consummated = true;
        removeListeners();
        return typeof callback === "function" ? callback(moveEvent) : void 0;
      }
    };
    handleUp = function(upEvent) {
      if (!consummated) {
        if (typeof notConsummatedCallback === "function") {
          notConsummatedCallback(upEvent);
        }
      }
      return removeListeners();
    };
    removeListeners = function() {
      window.removeEventListener("mousemove", handleMove);
      return window.removeEventListener("mouseup", handleUp);
    };
    window.addEventListener("mousemove", handleMove);
    return window.addEventListener("mouseup", handleUp);
  };

}).call(this);
}, "view/ApplyRowView": function(exports, require, module) {(function() {
  var ApplyInternalsView, ApplyRowView, ApplyThumbnailView, ApplyView, DataForMixin, GraphView, Param, ParamSlotView, ParamView, PossibleApplyView, ProvisionalApply, ProvisionalApplyView, R, StartTranscludeMixin, cx, onceDragConsummated;

  R = React.DOM;

  cx = React.addons.classSet;

  Param = require("../model/Param");

  ProvisionalApply = require("../model/ProvisionalApply");

  onceDragConsummated = require("../util/onceDragConsummated");

  DataForMixin = require("./mixins/DataForMixin");

  StartTranscludeMixin = require("./mixins/StartTranscludeMixin");

  ParamView = require("./ParamView");

  GraphView = require("./rendering/GraphView");

  ApplyView = React.createClass({
    handleMouseDown: function(e) {
      var apply, block, el, isDraggingCopy, myHeight, myWidth, offset, rect, _ref;
      _ref = this.props, apply = _ref.apply, block = _ref.block, isDraggingCopy = _ref.isDraggingCopy;
      if (editor.dragging != null) {
        return;
      }
      if (key.shift) {
        editor.setRangeSelection(block, apply);
      } else {
        if (editor.isApplySelected(block, apply)) {
          onceDragConsummated(e, null, (function(_this) {
            return function() {
              return editor.setSingleSelection(block, apply);
            };
          })(this));
        } else {
          editor.setSingleSelection(block, apply);
        }
      }
      if (apply.headParam() == null) {
        return editor.dragging = {};
      } else {
        el = this.getDOMNode();
        rect = el.getMarginRect();
        myWidth = rect.width;
        myHeight = rect.height;
        offset = {
          x: e.clientX - rect.left,
          y: e.clientY - rect.top
        };
        editor.dragging = {
          cursor: "-webkit-grabbing"
        };
        return onceDragConsummated(e, (function(_this) {
          return function() {
            return editor.dragging = {
              cursor: "-webkit-grabbing",
              offset: offset,
              apply: apply,
              placeholderHeight: myHeight,
              render: function() {
                return R.div({
                  style: {
                    "min-width": myWidth,
                    height: myHeight,
                    overflow: "hidden",
                    "background-color": "#fff"
                  }
                }, ApplyView({
                  apply: apply,
                  isDraggingCopy: true
                }));
              },
              onMove: function(e) {
                var applyEl, applyEls, insertAfterEl, refApply, refBlock, _i, _len, _ref1, _ref2;
                insertAfterEl = null;
                applyEls = document.querySelectorAll(".applyRow");
                for (_i = 0, _len = applyEls.length; _i < _len; _i++) {
                  applyEl = applyEls[_i];
                  if (applyEl.querySelector(".applyPlaceholder")) {
                    continue;
                  }
                  rect = applyEl.getBoundingClientRect();
                  if ((rect.bottom + myHeight * 1.5 > (_ref1 = e.clientY) && _ref1 > rect.top + myHeight / 2) && (rect.left < (_ref2 = e.clientX) && _ref2 < rect.right)) {
                    insertAfterEl = applyEl;
                  }
                }
                block.removeApply(apply);
                if (insertAfterEl) {
                  refApply = insertAfterEl.dataFor.props.apply;
                  refBlock = insertAfterEl.dataFor.props.block;
                  return refBlock.insertApplyAfter(apply, refApply);
                }
              }
            };
          };
        })(this));
      }
    },
    render: function() {
      var apply, block, classNames, isDraggingCopy, _ref, _ref1;
      _ref = this.props, apply = _ref.apply, block = _ref.block, isDraggingCopy = _ref.isDraggingCopy;
      if (!isDraggingCopy && apply === ((_ref1 = editor.dragging) != null ? _ref1.apply : void 0)) {
        return R.div({
          className: "applyPlaceholder",
          style: {
            height: editor.dragging.placeholderHeight
          }
        });
      }
      classNames = cx({
        apply: true,
        hovered: apply === editor.hoveredApply,
        isStart: typeof apply.isStart === "function" ? apply.isStart() : void 0,
        isSelected: editor.isApplySelected(block, apply)
      });
      return R.div({
        className: classNames,
        style: {
          cursor: "-webkit-grab"
        },
        onMouseDown: this.handleMouseDown
      }, ApplyInternalsView({
        apply: apply
      }));
    }
  });

  ApplyInternalsView = React.createClass({
    render: function() {
      var apply;
      apply = this.props.apply;
      return R.div({
        className: "applyInternals"
      }, R.div({
        className: "fnTitle"
      }, apply.fn.title), apply.allParams().map(function(param, paramIndex) {
        if (paramIndex === 0) {
          return null;
        }
        return ParamSlotView({
          param: param,
          apply: apply,
          paramIndex: paramIndex,
          key: paramIndex
        });
      }), ApplyThumbnailView({
        apply: apply
      }));
    }
  });

  ParamSlotView = React.createClass({
    mixins: [DataForMixin],
    handleTransclusionDrop: function(p) {
      var apply, param, paramIndex, _ref;
      _ref = this.props, param = _ref.param, apply = _ref.apply, paramIndex = _ref.paramIndex;
      return apply.setParam(paramIndex, p);
    },
    render: function() {
      var apply, param, paramIndex, _ref;
      _ref = this.props, param = _ref.param, apply = _ref.apply, paramIndex = _ref.paramIndex;
      return R.div({
        className: "paramSlot"
      }, param instanceof Param ? ParamView({
        param: param
      }) : ApplyThumbnailView({
        apply: param
      }));
    }
  });

  ApplyThumbnailView = React.createClass({
    mixins: [StartTranscludeMixin],
    handleMouseDown: function(e) {
      var apply, render;
      apply = this.props.apply;
      render = (function(_this) {
        return function() {
          return ApplyThumbnailView({
            apply: apply
          });
        };
      })(this);
      return this.startTransclude(e, apply, render);
    },
    handleMouseEnter: function(e) {
      return editor.hoveredApply = this.props.apply;
    },
    handleMouseLeave: function(e) {
      return editor.hoveredApply = null;
    },
    render: function() {
      var apply, graphViews, i, param, styleOpts, _i, _len, _ref;
      apply = this.props.apply;
      graphViews = [];
      if (!(typeof apply.isStart === "function" ? apply.isStart() : void 0)) {
        _ref = apply.allParams();
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          param = _ref[i];
          if (param instanceof Param && param !== editor.xParam) {
            styleOpts = config.styles.param;
          } else {
            styleOpts = config.styles.apply;
          }
          graphViews.push(GraphView({
            apply: param,
            styleOpts: styleOpts,
            key: i
          }));
        }
      }
      if (apply === editor.hoveredApply) {
        styleOpts = config.styles.hoveredApply;
      } else {
        styleOpts = config.styles.resultApply;
      }
      graphViews.push(GraphView({
        apply: apply,
        styleOpts: styleOpts,
        key: "result"
      }));
      return R.div({
        className: "applyThumbnail",
        style: {
          cursor: "-webkit-grab"
        },
        onMouseDown: this.handleMouseDown,
        onMouseEnter: this.handleMouseEnter,
        onMouseLeave: this.handleMouseLeave
      }, graphViews);
    }
  });

  PossibleApplyView = React.createClass({
    handleMouseEnter: function() {
      var apply, block, possibleApply, _ref;
      _ref = this.props, apply = _ref.apply, block = _ref.block, possibleApply = _ref.possibleApply;
      apply.stagedApply = possibleApply;
      return editor.hoveredParam = possibleApply.allParams()[1];
    },
    handleMouseLeave: function() {
      var apply, block, possibleApply, _ref;
      _ref = this.props, apply = _ref.apply, block = _ref.block, possibleApply = _ref.possibleApply;
      apply.stagedApply = null;
      return editor.hoveredParam = null;
    },
    handleClick: function() {
      var apply, block, possibleApply, _ref;
      _ref = this.props, apply = _ref.apply, block = _ref.block, possibleApply = _ref.possibleApply;
      block.replaceApply(possibleApply, apply);
      return editor.hoveredParam = null;
    },
    render: function() {
      var apply, block, classNames, possibleApply, _ref;
      _ref = this.props, apply = _ref.apply, block = _ref.block, possibleApply = _ref.possibleApply;
      classNames = cx({
        possibleApply: true,
        stagedPossibleApply: apply.stagedApply === possibleApply
      });
      return R.div({
        className: classNames,
        onClick: this.handleClick,
        onMouseEnter: this.handleMouseEnter,
        onMouseLeave: this.handleMouseLeave
      }, ApplyInternalsView({
        apply: possibleApply
      }));
    }
  });

  ProvisionalApplyView = React.createClass({
    render: function() {
      var apply, block, _ref;
      _ref = this.props, apply = _ref.apply, block = _ref.block;
      return R.div({
        className: "provisionalApply"
      }, apply.possibleApplies.map(function(possibleApply) {
        return PossibleApplyView({
          apply: apply,
          block: block,
          possibleApply: possibleApply,
          key: possibleApply.__id
        });
      }));
    }
  });

  module.exports = ApplyRowView = React.createClass({
    mixins: [DataForMixin],
    toggleProvisionalApply: function() {
      var apply, block, nextApply, _ref;
      _ref = this.props, apply = _ref.apply, block = _ref.block;
      nextApply = block.nextApply(apply);
      if (nextApply instanceof ProvisionalApply) {
        return block.removeApply(nextApply);
      } else {
        return block.insertNewApplyAfter(apply);
      }
    },
    render: function() {
      var apply, block, _ref;
      _ref = this.props, apply = _ref.apply, block = _ref.block;
      if (apply instanceof ProvisionalApply) {
        return R.div({
          className: "applyRow"
        }, ProvisionalApplyView({
          apply: apply,
          block: block
        }));
      } else {
        return R.div({
          className: "applyRow"
        }, ApplyView({
          apply: apply,
          block: block
        }), R.button({
          className: "addApplyButton",
          onClick: this.toggleProvisionalApply
        }, "+"));
      }
    }
  });

}).call(this);
}, "view/BlockView": function(exports, require, module) {(function() {
  var ApplyRowView, BlockView, R, cx;

  R = React.DOM;

  cx = React.addons.classSet;

  ApplyRowView = require("./ApplyRowView");

  module.exports = BlockView = React.createClass({
    render: function() {
      var block;
      block = this.props.block;
      return R.div({
        className: "block"
      }, block.applies().map(function(apply) {
        return ApplyRowView({
          apply: apply,
          block: block,
          key: apply.__id
        });
      }));
    }
  });

}).call(this);
}, "view/DraggingView": function(exports, require, module) {(function() {
  var DraggingView, R, cx;

  R = React.DOM;

  cx = React.addons.classSet;

  module.exports = DraggingView = React.createClass({
    render: function() {
      var _ref;
      return R.div({}, ((_ref = editor.dragging) != null ? _ref.render : void 0) ? R.div({
        className: "draggingObject",
        style: {
          left: editor.mousePosition.x - editor.dragging.offset.x,
          top: editor.mousePosition.y - editor.dragging.offset.y
        }
      }, editor.dragging.render()) : void 0, editor.dragging ? R.div({
        className: "draggingOverlay"
      }) : void 0);
    }
  });

}).call(this);
}, "view/EditorView": function(exports, require, module) {(function() {
  var BlockView, DraggingView, EditorView, MainGraphView, OutputSwitchView, R, cx;

  R = React.DOM;

  cx = React.addons.classSet;

  BlockView = require("./BlockView");

  MainGraphView = require("./MainGraphView");

  DraggingView = require("./DraggingView");

  OutputSwitchView = React.createClass({
    handleChange: function(e) {
      editor.outputSwitch = e.target.selectedOptions[0].value;
      if (editor.outputSwitch === "Cartesian") {
        return editor.shaderView = false;
      } else if (editor.outputSwitch === "Color Map") {
        editor.shaderView = true;
        return editor.contourView = false;
      } else if (editor.outputSwitch === "Contour Map") {
        editor.shaderView = true;
        return editor.contourView = true;
      }
    },
    render: function() {
      return R.div({
        className: "outputSwitch"
      }, R.select({
        value: editor.outputSwitch,
        onChange: this.handleChange,
        ref: "select"
      }, R.option({
        value: "Cartesian"
      }, "Cartesian"), R.option({
        value: "Color Map"
      }, "Color Map"), R.option({
        value: "Contour Map"
      }, "Contour Map")));
    }
  });

  module.exports = EditorView = React.createClass({
    handleMouseDown: function(e) {
      var _ref;
      if (editor.dragging != null) {
        if (!editor.dragging.text) {
          e.preventDefault();
          if ((_ref = document.activeElement) != null) {
            _ref.blur();
          }
          return document.activeElement = document.body;
        }
      } else {
        return editor.unsetSelection();
      }
    },
    render: function() {
      var classNames, _ref, _ref1;
      classNames = cx({
        editor: true,
        dragging: editor.dragging != null
      });
      return R.div({
        className: classNames,
        style: {
          cursor: (_ref = (_ref1 = editor.dragging) != null ? _ref1.cursor : void 0) != null ? _ref : ""
        },
        onMouseDown: this.handleMouseDown
      }, MainGraphView({}), R.div({
        className: "manager"
      }, BlockView({
        block: editor.rootBlock
      })), OutputSwitchView({}), R.div({
        className: "dragging"
      }, DraggingView({})));
    }
  });

}).call(this);
}, "view/MainGraphView": function(exports, require, module) {(function() {
  var GraphView, GridView, MainCartesianGraphView, MainGraphView, MainShaderGraphView, Param, R, ShaderGraphView, config, cx, lerp;

  R = React.DOM;

  cx = React.addons.classSet;

  lerp = require("../util/lerp");

  Param = require("../model/Param");

  GridView = require("./rendering/GridView");

  GraphView = require("./rendering/GraphView");

  ShaderGraphView = require("./rendering/ShaderGraphView");

  config = require("../config");

  MainCartesianGraphView = React.createClass({
    render: function() {
      var apply, graphViews, i, neg, param, paramIndex, resultApply, spreadDistance, spreadNum, spreadOffset, styleOpts, _i, _j, _k, _len, _len1, _ref, _ref1;
      graphViews = [];
      resultApply = editor.rootBlock.root;
      if (editor.spreadParam()) {
        spreadDistance = 0.5;
        spreadNum = 5;
        for (i = _i = 1; 1 <= spreadNum ? _i < spreadNum : _i > spreadNum; i = 1 <= spreadNum ? ++_i : --_i) {
          _ref = [-1, 1];
          for (_j = 0, _len = _ref.length; _j < _len; _j++) {
            neg = _ref[_j];
            if (neg === -1) {
              styleOpts = _.clone(config.styles.spreadNegative);
            } else {
              styleOpts = _.clone(config.styles.spreadPositive);
            }
            styleOpts.globalAlpha = lerp(i, 1, spreadNum, config.spreadOpacityMax, config.spreadOpacityMin);
            spreadOffset = spreadDistance * i * neg;
            graphViews.push(GraphView({
              apply: resultApply,
              key: "spread" + (i * neg),
              styleOpts: styleOpts,
              spreadOffset: spreadOffset
            }));
          }
        }
      }
      graphViews.push(GraphView({
        apply: resultApply,
        key: "result",
        styleOpts: config.styles.resultApply
      }));
      if (apply = editor.hoveredApply) {
        if (!(typeof apply.isStart === "function" ? apply.isStart() : void 0)) {
          _ref1 = apply.allParams();
          for (paramIndex = _k = 0, _len1 = _ref1.length; _k < _len1; paramIndex = ++_k) {
            param = _ref1[paramIndex];
            if (param instanceof Param && param !== editor.xParam) {
              styleOpts = config.styles.param;
            } else {
              styleOpts = config.styles.apply;
            }
            graphViews.push(GraphView({
              apply: param,
              key: "param" + paramIndex,
              styleOpts: styleOpts
            }));
          }
        }
        graphViews.push(GraphView({
          apply: apply,
          key: "hoveredApply",
          styleOpts: config.styles.hoveredApply
        }));
      }
      if (param = editor.hoveredParam) {
        graphViews.push(GraphView({
          apply: param,
          key: "hoveredParam",
          styleOpts: config.styles.hoveredParam
        }));
      }
      return R.span({}, GridView({}), graphViews);
    }
  });

  MainShaderGraphView = React.createClass({
    render: function() {
      var _ref;
      return R.span({
        style: {
          opacity: config.shaderOpacity
        }
      }, ShaderGraphView({
        apply: (_ref = editor.hoveredApply) != null ? _ref : editor.rootBlock.root
      }), GridView({}));
    }
  });

  module.exports = MainGraphView = React.createClass({
    render: function() {
      return R.div({
        className: "main"
      }, editor.shaderView ? MainShaderGraphView({}) : MainCartesianGraphView({}));
    }
  });

}).call(this);
}, "view/ParamView": function(exports, require, module) {(function() {
  var ContentEditableMixin, ParamTitleView, ParamValueView, ParamView, R, StartTranscludeMixin, cx, onceDragConsummated, truncate;

  R = React.DOM;

  cx = React.addons.classSet;

  onceDragConsummated = require("../util/onceDragConsummated");

  StartTranscludeMixin = require("./mixins/StartTranscludeMixin");

  truncate = function(value) {
    var s;
    s = value.toFixed(4);
    if (s.indexOf(".") !== -1) {
      s = s.replace(/\.?0*$/, "");
    }
    if (s === "-0") {
      s = "0";
    }
    return s;
  };

  ContentEditableMixin = {
    isFocused: function() {
      if (!this.isMounted()) {
        return false;
      }
      return this.getDOMNode() === document.activeElement;
    },
    cleanAndGetValue: function() {
      var el, text;
      el = this.getDOMNode();
      text = el.textContent;
      if (el.innerHTML !== text) {
        el.innerHTML = text;
      }
      return text;
    },
    focus: function() {
      return this.getDOMNode().focus();
    },
    focusAndSelect: function() {
      this.focus();
      document.execCommand("selectAll", false, null);
      return this.forceUpdate();
    }
  };

  ParamValueView = React.createClass({
    mixins: [ContentEditableMixin],
    shouldComponentUpdate: function() {
      return !this.isFocused();
    },
    cursor: function() {
      if (this.isFocused()) {
        return "text";
      } else if (this.props.param.axis === "x") {
        return "ew-resize";
      } else {
        return "ns-resize";
      }
    },
    handleMouseDown: function(e) {
      var originalValue, originalX, originalY, param;
      if (this.isFocused()) {
        editor.dragging = {
          text: true
        };
        return;
      }
      param = this.props.param;
      originalX = e.clientX;
      originalY = e.clientY;
      originalValue = param.value;
      editor.dragging = {
        cursor: this.cursor(),
        onMove: (function(_this) {
          return function(e) {
            var d, dx, dy, multiplier;
            editor.hoveredParam = param;
            dx = e.clientX - originalX;
            dy = -(e.clientY - originalY);
            d = param.axis === "x" ? dx : dy;
            multiplier = 0.1;
            return param.value = originalValue + d * multiplier;
          };
        })(this),
        onUp: (function(_this) {
          return function(e) {
            return editor.hoveredParam = null;
          };
        })(this)
      };
      return onceDragConsummated(e, null, (function(_this) {
        return function() {
          return _this.focusAndSelect();
        };
      })(this));
    },
    handleInput: function(e) {
      return this.props.param.value = +this.cleanAndGetValue();
    },
    render: function() {
      var param;
      param = this.props.param;
      return R.span({
        className: "paramValue",
        contentEditable: true,
        onMouseDown: this.handleMouseDown,
        onDoubleClick: this.focusAndSelect,
        onInput: this.handleInput,
        style: {
          cursor: this.cursor()
        }
      }, (function(_this) {
        return function() {
          if (editor.xParam === param) {
            return R.i({}, "x");
          } else if (editor.yParam === param) {
            return R.i({}, "y");
          } else {
            return truncate(param.value);
          }
        };
      })(this)());
    }
  });

  ParamTitleView = React.createClass({
    mixins: [ContentEditableMixin, StartTranscludeMixin],
    cursor: function() {
      if (this.isFocused()) {
        return "text";
      } else {
        return "-webkit-grab";
      }
    },
    handleMouseDown: function(e) {
      var param, render;
      if (this.isFocused()) {
        editor.dragging = {
          text: true
        };
        return;
      }
      param = this.props.param;
      render = (function(_this) {
        return function() {
          return ParamView({
            param: param
          });
        };
      })(this);
      this.startTransclude(e, param, render);
      return onceDragConsummated(e, null, (function(_this) {
        return function() {
          return _this.focusAndSelect();
        };
      })(this));
    },
    handleInput: function() {
      return this.props.param.title = this.cleanAndGetValue();
    },
    render: function() {
      var param;
      param = this.props.param;
      return R.span({
        className: "paramTitle",
        contentEditable: true,
        onMouseDown: this.handleMouseDown,
        onDoubleClick: this.focusAndSelect,
        onInput: this.handleInput,
        style: {
          cursor: this.cursor()
        }
      }, param.title);
    }
  });

  module.exports = ParamView = React.createClass({
    handleMouseDown: function(e) {
      var param;
      param = this.props.param;
      if (key.command) {
        if (param.axis === "result") {
          return param.axis = "x";
        } else {
          return param.axis = "result";
        }
      } else if (key.shift) {
        if (editor.xParam === param) {
          return editor.xParam = null;
        } else {
          return editor.xParam = param;
        }
      } else if (key.option) {
        if (editor.yParam === param) {
          return editor.yParam = null;
        } else {
          return editor.yParam = param;
        }
      }
    },
    handleMouseEnter: function() {
      return editor.hoveredParam = this.props.param;
    },
    handleMouseLeave: function() {
      return editor.hoveredParam = null;
    },
    render: function() {
      var classNames;
      classNames = cx({
        param: true,
        hovered: editor.hoveredParam === this.props.param
      });
      return R.div({
        className: classNames,
        onMouseDown: this.handleMouseDown,
        onMouseEnter: this.handleMouseEnter,
        onMouseLeave: this.handleMouseLeave
      }, ParamTitleView({
        param: this.props.param
      }), ParamValueView({
        param: this.props.param
      }));
    }
  });

}).call(this);
}, "view/mixins/DataForMixin": function(exports, require, module) {(function() {
  var DataForMixin;

  module.exports = DataForMixin = {
    componentDidMount: function() {
      return this.updateDataForAnnotation();
    },
    componentDidUpdate: function() {
      return this.updateDataForAnnotation();
    },
    updateDataForAnnotation: function() {
      var el;
      el = this.getDOMNode();
      return el.dataFor = this;
    }
  };

}).call(this);
}, "view/mixins/StartTranscludeMixin": function(exports, require, module) {(function() {
  var StartTranscludeMixin, onceDragConsummated;

  onceDragConsummated = require("../../util/onceDragConsummated");

  module.exports = StartTranscludeMixin = {
    startTransclude: function(e, apply, render) {
      var el, offset, rect;
      el = this.getDOMNode();
      rect = el.getBoundingClientRect();
      offset = {
        x: e.clientX - rect.left,
        y: e.clientY - rect.top
      };
      editor.dragging = {
        cursor: "-webkit-grabbing"
      };
      return onceDragConsummated(e, (function(_this) {
        return function() {
          return editor.dragging = {
            cursor: "-webkit-grabbing",
            offset: offset,
            render: render,
            transclusion: apply,
            onUp: function(e) {
              var overlay, paramSlotEl;
              overlay = document.querySelector(".draggingOverlay");
              overlay.style.display = "none";
              el = document.elementFromPoint(e.clientX, e.clientY);
              overlay.style.display = "block";
              paramSlotEl = el.closest(function(el) {
                var _ref;
                return (_ref = el.dataFor) != null ? _ref.handleTransclusionDrop : void 0;
              });
              return paramSlotEl != null ? paramSlotEl.dataFor.handleTransclusionDrop(apply) : void 0;
            }
          };
        };
      })(this));
    }
  };

}).call(this);
}, "view/rendering/CanvasView": function(exports, require, module) {(function() {
  var CanvasView, R, cx;

  R = React.DOM;

  cx = React.addons.classSet;

  module.exports = CanvasView = React.createClass({
    draw: function() {
      var canvas;
      canvas = this.getDOMNode();
      return this.props.drawFn(canvas);
    },
    sizeCanvas: function() {
      var canvas, rect;
      canvas = this.getDOMNode();
      rect = canvas.getBoundingClientRect();
      if (canvas.width !== rect.width || canvas.height !== rect.height) {
        canvas.width = rect.width;
        canvas.height = rect.height;
        return true;
      }
      return false;
    },
    handleResize: function() {
      if (this.sizeCanvas()) {
        return this.draw();
      }
    },
    componentDidMount: function() {
      this.sizeCanvas();
      this.draw();
      return window.addEventListener("resize", this.handleResize);
    },
    componentWillUnmount: function() {
      return window.removeEventListener("resize", this.handleResize);
    },
    render: function() {
      return R.canvas({});
    }
  });

}).call(this);
}, "view/rendering/Graph": function(exports, require, module) {(function() {
  var Graph, config, drawLine, lerp, ticks;

  config = require("../../config");

  lerp = require("../../util/lerp");


  /*
  
  Need to snap to grid lines
    given a y value and a tolerance (pixels), find closest grid line (i.e. return a y value, either the same or snapped)
  
  Need to see how close a point is to an object, for hit detection
   */

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

  module.exports = Graph = (function() {
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
      var axesColor, axesOpacity, color, cx, cxMax, cxMin, cy, cyMax, cyMin, fromLocal, labelColor, labelDistance, labelOpacity, largeSpacing, majorColor, majorOpacity, minorColor, minorOpacity, sizeX, sizeY, smallSpacing, text, textHeight, toLocal, x, y, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8;
      this.ctx.save();
      sizeX = this.xMax - this.xMin;
      sizeY = this.yMax - this.yMin;
      cxMin = 0;
      cxMax = this.width();
      cyMin = this.height();
      cyMax = 0;
      toLocal = (function(_this) {
        return function(_arg) {
          var cx, cy;
          cx = _arg[0], cy = _arg[1];
          return [lerp(cx, cxMin, cxMax, _this.xMin, _this.xMax), lerp(cy, cyMin, cyMax, _this.yMin, _this.yMax)];
        };
      })(this);
      fromLocal = (function(_this) {
        return function(_arg) {
          var x, y;
          x = _arg[0], y = _arg[1];
          return [lerp(x, _this.xMin, _this.xMax, cxMin, cxMax), lerp(y, _this.yMin, _this.yMax, cyMin, cyMax)];
        };
      })(this);
      labelDistance = 5;
      color = config.gridColor;
      minorOpacity = 0.3;
      majorOpacity = 0.4;
      axesOpacity = 1.0;
      labelOpacity = 1.0;
      textHeight = 12;
      minorColor = "rgba(" + color + ", " + minorOpacity + ")";
      majorColor = "rgba(" + color + ", " + majorOpacity + ")";
      axesColor = "rgba(" + color + ", " + axesOpacity + ")";
      labelColor = "rgba(" + color + ", " + labelOpacity + ")";
      _ref = this.findSpacing(), largeSpacing = _ref[0], smallSpacing = _ref[1];
      this.ctx.lineWidth = 0.5;
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
      var cx, cxMax, cxMin, cy, cyMax, cyMin, dCy, i, lastCx, lastCy, lastSample, sizeX, sizeY, x, y, _i;
      this.ctx.save();
      this.setStyleOpts(styleOpts);
      sizeX = this.xMax - this.xMin;
      sizeY = this.yMax - this.yMin;
      cxMin = 0;
      cxMax = this.width();
      cyMin = this.height();
      cyMax = 0;

      /*
      
      All this lastCy, etc. crap is to optimize having fewer lineTo calls. It
      fixes weird artifacting with straight lines in Chrome.
       */
      this.ctx.beginPath();
      lastSample = this.width() / config.resolution;
      lastCx = null;
      lastCy = null;
      dCy = null;
      for (i = _i = 0; 0 <= lastSample ? _i <= lastSample : _i >= lastSample; i = 0 <= lastSample ? ++_i : --_i) {
        cx = i * config.resolution;
        x = lerp(cx, cxMin, cxMax, this.xMin, this.xMax);
        y = fn(x);
        cy = lerp(y, this.yMin, this.yMax, cyMin, cyMax);
        if (lastCy == null) {
          this.ctx.moveTo(cx, cy);
        }
        if (dCy != null) {
          if (Math.abs((cy - lastCy) - dCy) > .000001) {
            this.ctx.lineTo(lastCx, lastCy);
          }
        }
        if (lastCy != null) {
          dCy = cy - lastCy;
        }
        lastCx = cx;
        lastCy = cy;
      }
      this.ctx.lineTo(cx, cy);
      this.ctx.stroke();
      return this.ctx.restore();
    };

    Graph.prototype.drawHorizontalLine = function(y, styleOpts) {
      var cxMax, cxMin, cy, cyMax, cyMin;
      this.ctx.save();
      this.setStyleOpts(styleOpts);
      cxMin = 0;
      cxMax = this.width();
      cyMin = this.height();
      cyMax = 0;
      cy = lerp(y, this.yMin, this.yMax, cyMin, cyMax);
      this.ctx.beginPath();
      this.ctx.moveTo(cxMin, cy);
      this.ctx.lineTo(cxMax, cy);
      this.ctx.stroke();
      return this.ctx.restore();
    };

    Graph.prototype.drawVerticalLine = function(x, styleOpts) {
      var cx, cxMax, cxMin, cyMax, cyMin;
      this.ctx.save();
      this.setStyleOpts(styleOpts);
      cxMin = 0;
      cxMax = this.width();
      cyMin = this.height();
      cyMax = 0;
      cx = lerp(x, this.xMin, this.xMax, cxMin, cxMax);
      this.ctx.beginPath();
      this.ctx.moveTo(cx, cyMin);
      this.ctx.lineTo(cx, cyMax);
      this.ctx.stroke();
      return this.ctx.restore();
    };

    Graph.prototype.setStyleOpts = function(styleOpts) {
      return _.extend(this.ctx, config.styles["default"], styleOpts);
    };

    return Graph;

  })();

}).call(this);
}, "view/rendering/GraphView": function(exports, require, module) {(function() {
  var CanvasView, Graph, GraphView, Param, R, cx;

  R = React.DOM;

  cx = React.addons.classSet;

  CanvasView = require("./CanvasView");

  Graph = require("./Graph");

  Param = require("../../model/Param");

  module.exports = GraphView = React.createClass({
    getDefaultProps: function() {
      return {
        spreadOffset: 0
      };
    },
    drawFn: function(canvas) {
      var apply, graph, graphFn, s, spreadOffset, styleOpts, _ref, _ref1;
      _ref = this.props, apply = _ref.apply, spreadOffset = _ref.spreadOffset, styleOpts = _ref.styleOpts;
      graph = canvas.graph != null ? canvas.graph : canvas.graph = new Graph(canvas, -10, 10, -10, 10);
      graph.clear();
      s = (_ref1 = this.compileString_) != null ? _ref1 : apply.compileString();
      graphFn = eval("(function (x) { var spreadOffset = " + spreadOffset + "; return " + s + "; })");
      if (apply instanceof Param && apply !== editor.xParam) {
        if (apply.axis === "x") {
          return graph.drawVerticalLine(graphFn(0), styleOpts);
        } else if (apply.axis === "result") {
          return graph.drawHorizontalLine(graphFn(0), styleOpts);
        }
      } else {
        return graph.drawGraph(graphFn, styleOpts);
      }
    },
    render: function() {
      return CanvasView({
        drawFn: this.drawFn,
        ref: "canvas"
      });
    },
    componentDidUpdate: function() {
      var apply, drawOptions, spreadOffset, styleOpts, _ref;
      _ref = this.props, apply = _ref.apply, spreadOffset = _ref.spreadOffset, styleOpts = _ref.styleOpts;
      this.compileString_ = apply.compileString();
      drawOptions = _.extend({
        compileString_: this.compileString_,
        spreadOffset: spreadOffset,
        axis: apply.axis
      }, styleOpts);
      if (_.isEqual(drawOptions, this.lastDrawOptions_)) {
        return;
      }
      this.lastDrawOptions_ = drawOptions;
      return this.refs.canvas.draw();
    }
  });

}).call(this);
}, "view/rendering/GridView": function(exports, require, module) {(function() {
  var CanvasView, Graph, GridView, R, cx;

  R = React.DOM;

  cx = React.addons.classSet;

  CanvasView = require("./CanvasView");

  Graph = require("./Graph");

  module.exports = GridView = React.createClass({
    drawFn: function(canvas) {
      var graph;
      graph = canvas.graph != null ? canvas.graph : canvas.graph = new Graph(canvas, -10, 10, -10, 10);
      graph.clear();
      return graph.drawGrid();
    },
    render: function() {
      return CanvasView({
        drawFn: this.drawFn
      });
    }
  });

}).call(this);
}, "view/rendering/Shader": function(exports, require, module) {
/*
opts
  canvas: Canvas DOM element
  vertex: glsl source string
  fragment: glsl source string
  uniforms: a hash of names to values, the type is inferred as follows:
    Number or [Number]: float
    [Number, Number]: vec2
    [Number, Number, Number]: vec3
    [Number, Number, Number, Number]: vec4
    DOMElement: Sampler2D (e.g. Image/Video/Canvas)
    TODO: a way to force an arbitrary type


to set uniforms,
 */

(function() {
  var Shader,
    __hasProp = {}.hasOwnProperty;

  module.exports = Shader = (function() {
    function Shader(canvas) {
      this.canvas = canvas;
      this.vertexSrc = null;
      this.fragmentSrc = null;
      this.uniforms = {};
      this.gl_ = this.canvas.getContext("experimental-webgl", {
        premultipliedAlpha: false
      });
      this.program_ = this.gl_.createProgram();
      this.shaders_ = {};
      this.textures_ = [];
    }

    Shader.prototype.setVertexSrc = function(src) {
      this.vertexSrc = src;
      return this.replaceShader_(this.vertexSrc, this.gl_.VERTEX_SHADER);
    };

    Shader.prototype.setFragmentSrc = function(src) {
      this.fragmentSrc = src;
      return this.replaceShader_(this.fragmentSrc, this.gl_.FRAGMENT_SHADER);
    };

    Shader.prototype.replaceShader_ = function(src, type) {
      var shader;
      if (this.shaders_[type]) {
        this.gl_.detachShader(this.program_, this.shaders_[type]);
      }
      shader = this.gl_.createShader(type);
      this.gl_.shaderSource(shader, src);
      this.gl_.compileShader(shader);
      this.gl_.attachShader(this.program_, shader);
      this.gl_.deleteShader(shader);
      this.shaders_[type] = shader;
      return this.linkAndUseShaders_();
    };

    Shader.prototype.linkAndUseShaders_ = function() {
      if (this.vertexSrc && this.fragmentSrc) {
        this.gl_.linkProgram(this.program_);
        this.gl_.useProgram(this.program_);
        return this.refreshUniforms_();
      }
    };

    Shader.prototype.setUniforms = function(uniforms) {
      this.uniforms = uniforms;
      return this.refreshUniforms_();
    };

    Shader.prototype.refreshUniforms_ = function() {
      var name, value, _ref, _results;
      _ref = this.uniforms;
      _results = [];
      for (name in _ref) {
        if (!__hasProp.call(_ref, name)) continue;
        value = _ref[name];
        _results.push(this.setUniform_(name, value));
      }
      return _results;
    };

    Shader.prototype.setUniform_ = function(name, value) {
      var location, texture;
      location = this.gl_.getUniformLocation(this.program_, name);
      if (_.isNumber(value)) {
        return this.gl_.uniform1fv(location, [value]);
      } else if (_.isArray(value)) {
        switch (value.length) {
          case 1:
            return this.gl_.uniform1fv(location, value);
          case 2:
            return this.gl_.uniform2fv(location, value);
          case 3:
            return this.gl_.uniform3fv(location, value);
          case 4:
            return this.gl_.uniform4fv(location, value);
        }
      } else if (value.nodeName) {
        texture = this.getTexture(value);
        this.gl_.activeTexture(this.gl_.TEXTURE0 + texture.i);
        this.gl_.texImage2D(this.gl_.TEXTURE_2D, 0, this.gl_.RGBA, this.gl_.RGBA, this.gl_.UNSIGNED_BYTE, value);
        return this.gl_.uniform1i(location, texture.i);
      } else if (!value) {
        return false;
      }
    };

    Shader.prototype.draw = function() {
      if (!this.initialized_) {
        this.gl_.useProgram(this.program_);
        this.bufferAttribute_("vertexPosition", [-1.0, -1.0, 1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0]);
        this.initialized_ = true;
      }
      this.gl_.viewport(0, 0, this.gl_.canvas.width, this.gl_.canvas.height);
      return this.gl_.drawArrays(this.gl_.TRIANGLES, 0, 6);
    };

    Shader.prototype.bufferAttribute_ = function(attrib, data, size) {
      var buffer, location;
      if (size == null) {
        size = 2;
      }
      location = this.gl_.getAttribLocation(this.program_, attrib);
      buffer = this.gl_.createBuffer();
      this.gl_.bindBuffer(this.gl_.ARRAY_BUFFER, buffer);
      this.gl_.bufferData(this.gl_.ARRAY_BUFFER, new Float32Array(data), this.gl_.STATIC_DRAW);
      this.gl_.enableVertexAttribArray(location);
      return this.gl_.vertexAttribPointer(location, size, this.gl_.FLOAT, false, 0, 0);
    };

    return Shader;

  })();

}).call(this);
}, "view/rendering/ShaderGraphView": function(exports, require, module) {(function() {
  var CanvasView, R, Shader, ShaderGraphView, cx;

  R = React.DOM;

  cx = React.addons.classSet;

  CanvasView = require("./CanvasView");

  Shader = require("./Shader");

  module.exports = ShaderGraphView = React.createClass({
    drawFn: function(canvas) {
      var apply, colorMap, contourMap, fragmentSrc, s, shader, vertexSrc;
      apply = this.props.apply;
      shader = canvas.shader != null ? canvas.shader : canvas.shader = new Shader(canvas);
      s = apply.compileGlslString();
      vertexSrc = "precision mediump float;\n\nattribute vec3 vertexPosition;\n\nvoid main() {\n  gl_Position = vec4(vertexPosition, 1.0);\n}";
      colorMap = "float outputValue = compute(x, y);\ngl_FragColor = vec4(vec3(outputValue), 1);";
      contourMap = "float outputValue = contourMap(vec2(x, y));\ngl_FragColor = vec4(vec3(0.), outputValue);";
      fragmentSrc = "precision mediump float;\n\nuniform vec2 resolution;\n\nfloat compute(float x, float y) {\n  return " + s + ";\n}\n\nfloat contourMap(vec2 pos) {\n  float samples = 5.;\n  float numSamples = samples * samples;\n  vec2 step = ((40. / resolution)) / samples;\n\n  float count = 0.;\n  float min = 0.;\n  float processed = 0.;\n\n  for (float i = 0.0; i < 5.; i++) {\n    for (float  j = 0.0; j < 5.; j++) {\n      float f = compute(pos.x + i*step.x, pos.y + j*step.y);\n      float ff = floor(f);\n      if (processed == 0.) {\n        min = ff;\n      } else {\n        if (ff > min) {\n          count++;\n        } else if (ff < min) {\n          min = ff;\n          count = processed;\n        }\n      }\n      processed++;\n    }\n  }\n\n  float ns2 = numSamples / 2.;\n  return (ns2 - abs(count - ns2)) / ns2;\n}\n\nvoid main() {\n  vec2 p = gl_FragCoord.xy / resolution;\n  float x = mix(-10., 10., p.x);\n  float y = mix(-10., 10., p.y);\n\n  " + (editor.contourView ? contourMap : colorMap) + "\n}";
      shader.setVertexSrc(vertexSrc);
      shader.setFragmentSrc(fragmentSrc);
      shader.setUniforms({
        resolution: [canvas.width, canvas.height]
      });
      return shader.draw();
    },
    render: function() {
      return CanvasView({
        drawFn: this.drawFn,
        ref: "canvas"
      });
    },
    componentDidUpdate: function() {
      return this.refs.canvas.draw();
    }
  });

}).call(this);
}});
