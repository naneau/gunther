(function() {
  var Backbone, BoundModel, BoundProperty, Gunther, ItemSubView, SwitchedView, ViewSwitch, tag, _, _fn, _i, _len, _ref, _ref1, _ref2,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Gunther = {};

  if (typeof require !== "undefined" && require !== null) {
    module.exports = Gunther;
    _ = require('underscore');
    Backbone = require('backbone');
  } else {
    window.Gunther = Gunther;
    _ = window._, Backbone = window.Backbone;
  }

  if ((typeof _) === !'function') {
    throw new Error('Underscore.js must be loaded for Gunther to work');
  }

  Gunther.Helper = (function() {
    function Helper() {}

    Helper.createHtmlElement = function(description) {
      var attributeDefinition, element, previousClass, tagName, token, tokens, _i, _len;
      tokens = _.filter(description.split(/(?=\.)|(\[.+\=.+\])|(\:[a-z0-9]+)|(?=#)/), function(t) {
        return t != null;
      });
      if (!(tokens.length >= 1)) {
        throw new Error("Invalid element description " + description);
      }
      tagName = tokens[0];
      if (!/^[a-zA-Z0-9]+$/.test(tagName)) {
        throw new Error("Invalid tag name " + tagName);
      }
      element = $(document.createElement(tagName));
      if (tagName === description) {
        return element;
      }
      for (_i = 0, _len = tokens.length; _i < _len; _i++) {
        token = tokens[_i];
        if (token[0] === '#') {
          element.attr('id', token.substr(1));
        } else if (token[0] === '.') {
          previousClass = (element.attr('class')) != null ? (element.attr('class')) + ' ' : '';
          element.attr('class', previousClass + token.substr(1));
        } else if (token[0] === ':') {
          element.prop(token.substr(1), true);
        } else if (token[0] === '[' && (token[token.length = 1] = ']')) {
          attributeDefinition = ((token.substr(1)).substr(0, token.length - 2)).split('=');
          if (attributeDefinition.length !== 2) {
            continue;
          }
          element.attr(attributeDefinition[0], attributeDefinition[1]);
        }
      }
      return element;
    };

    Helper.animationFrame = function(callback) {
      return this._requestAnimationFrame.call(window, callback);
    };

    Helper._requestAnimationFrame = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback, element) {
      return window.setTimeout(function() {
        return callback(+new Date());
      }, 17);
    };

    return Helper;

  })();

  Gunther.IDGenerator = (function() {
    function IDGenerator() {
      this.value = 0;
    }

    IDGenerator.prototype.generate = function() {
      return this.value++;
    };

    return IDGenerator;

  })();

  BoundProperty = (function() {
    function BoundProperty(model, propertyNames, valueGenerator) {
      var propertyName, _i, _len, _ref,
        _this = this;
      this.model = model;
      this.propertyNames = propertyNames;
      this.valueGenerator = valueGenerator;
      if ((this.valueGenerator == null) && typeof this.propertyNames === 'string') {
        this.valueGenerator = function() {
          return _this.model.get(_this.propertyNames[0]);
        };
      }
      this.propertyNames = [].concat(this.propertyNames);
      _ref = this.propertyNames;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        propertyName = _ref[_i];
        this.model.bind("change:" + propertyName, function() {
          return _this.trigger('change', _this.getValue());
        });
      }
    }

    BoundProperty.prototype.getValue = function() {
      var generatedValue;
      generatedValue = this.valueGenerator();
      if (generatedValue instanceof Gunther.Template) {
        return generatedValue.render();
      } else {
        return generatedValue;
      }
    };

    BoundProperty.prototype.getValueInEl = function(el) {
      var element, generatedValue, _i, _len, _results;
      generatedValue = this.valueGenerator();
      if (generatedValue instanceof Gunther.Template) {
        return generatedValue.renderInto(el, this.model);
      } else if (generatedValue instanceof Backbone.View) {
        generatedValue.setElement(el);
        return generatedValue.render();
      } else {
        if (el.length > 0) {
          _results = [];
          for (_i = 0, _len = el.length; _i < _len; _i++) {
            element = el[_i];
            _results.push(element.textContent = generatedValue);
          }
          return _results;
        } else {
          return el.textContent = generatedValue;
        }
      }
    };

    return BoundProperty;

  })();

  _.extend(BoundProperty.prototype, Backbone.Events);

  BoundModel = (function() {
    function BoundModel() {
      var model, propertyName, templateAndArgs,
        _this = this;
      model = arguments[0], propertyName = arguments[1], templateAndArgs = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      this.model = model;
      this.propertyName = propertyName;
      this.template = templateAndArgs.pop();
      this.args = templateAndArgs;
      if (typeof this.template === 'function' && !(this.template instanceof Gunther.Template)) {
        this.template = new Gunther.Template(this.template);
      }
      this.currentValue = this.model.get(this.propertyName);
      this.model.bind("change:" + this.propertyName, function(parent) {
        var newValue;
        newValue = parent.get(_this.propertyName);
        if (newValue === _this.currentValue) {
          return;
        }
        _this.currentValue = newValue;
        return _this.trigger('change', newValue);
      });
    }

    BoundModel.prototype.getValueInEl = function(el) {
      return this.template.renderInto.apply(this.template, [].concat(el, this.model.get(this.propertyName), this.args));
    };

    return BoundModel;

  })();

  _.extend(BoundModel.prototype, Backbone.Events);

  Gunther.Template = (function() {
    Template.domParsers = [];

    Template.elementValue = function(generator, scope) {
      if (scope == null) {
        scope = {};
      }
      if (typeof generator === 'function') {
        return generator.apply(scope);
      }
      return generator;
    };

    Template.generateChildren = function(el, childFn, scope) {
      var childResult;
      childResult = Gunther.Template.elementValue(childFn, scope);
      if (childResult === void 0) {
        return;
      }
      if (typeof childResult !== 'object') {
        el.append(document.createTextNode(childResult));
      }
      if (childResult instanceof BoundProperty || childResult instanceof BoundModel) {
        childResult.getValueInEl(el);
        return childResult.bind('change', function(newVal) {
          el.empty();
          return childResult.getValueInEl(el);
        });
      } else if (childResult instanceof Gunther.SwitchedView) {
        return childResult.render();
      } else if (childResult instanceof Backbone.View) {
        childResult.setElement(el);
        return childResult.render();
      }
    };

    function Template(fn) {
      this.fn = fn;
      null;
    }

    Template.prototype.render = function() {
      var args, child, children, domParser, _i, _j, _len, _len1, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.root = $('<div />');
      this.current = this.root;
      this.fn.apply(this, args);
      children = this.root.contents();
      _ref = Gunther.Template.domParsers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        domParser = _ref[_i];
        for (_j = 0, _len1 = children.length; _j < _len1; _j++) {
          child = children[_j];
          domParser(child);
        }
      }
      return children;
    };

    Template.prototype.renderInto = function() {
      var args, child, children, el, _i, _len;
      el = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      children = this.render.apply(this, args);
      for (_i = 0, _len = children.length; _i < _len; _i++) {
        child = children[_i];
        ($(el)).append(child);
      }
      return children;
    };

    Template.prototype.subTemplate = function() {
      var args, template;
      template = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return template.renderInto.apply(template, [this.current].concat(__slice.call(args)));
    };

    Template.prototype.bind = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(BoundProperty, args, function(){});
    };

    Template.prototype.onModel = function(model, event, handler) {
      var current;
      current = this.current;
      return model.on(event, function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return handler.apply(this, [current].concat(args));
      });
    };

    Template.prototype.e = function() {
      var args, tagName;
      tagName = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return this.element.apply(this, [tagName].concat(__slice.call(args)));
    };

    Template.prototype.t = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.text.apply(this, args);
    };

    Template.prototype.attr = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.attribute.apply(this, args);
    };

    Template.prototype.prop = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.property.apply(this, args);
    };

    Template.prototype["class"] = function(className) {
      return this.attribute('class', className);
    };

    return Template;

  })();

  Gunther.Template.prototype.on = function(event, handler) {
    return this.current.bind(event, handler);
  };

  Gunther.Template.prototype.haltedOn = function(event, handler) {
    return this.current.bind(event, function(event) {
      event.stopPropagation();
      event.preventDefault();
      return handler(event);
    });
  };

  Gunther.Template.prototype.show = function(model, properties, resolver) {
    var element, property, show, _i, _len, _ref, _results,
      _this = this;
    element = this.current;
    if (resolver == null) {
      resolver = function(value) {
        return value;
      };
    }
    show = function(element, shown) {
      if (shown) {
        return ($(element)).show();
      } else {
        return ($(element)).hide();
      }
    };
    _ref = [].concat(properties);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      property = _ref[_i];
      _results.push((function(property) {
        model.on("change:" + property, function(model) {
          return show(element, resolver(model.get(property)));
        });
        return show(element, resolver(model.get(property)));
      })(property));
    }
    return _results;
  };

  Gunther.Template.prototype.hide = function(model, properties, resolver) {
    if (resolver == null) {
      resolver = function(value) {
        return value;
      };
    }
    return this.show(model, properties, function(value) {
      return !resolver(value);
    });
  };

  Gunther.Template.prototype.element = function() {
    var args, current, el, lastArgument, tagName;
    tagName = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    current = this.current;
    el = Gunther.Helper.createHtmlElement(tagName);
    this.current = el;
    lastArgument = args[args.length - 1];
    if (typeof lastArgument === 'function') {
      Gunther.Template.generateChildren(el, args.pop(), this);
    } else if (lastArgument instanceof BoundProperty || lastArgument instanceof BoundModel) {
      Gunther.Template.generateChildren(el, args.pop(), this);
    } else if (typeof lastArgument === 'string') {
      el.append(document.createTextNode(args.pop()));
    }
    current.append(el);
    this.current = current;
    return null;
  };

  Gunther.Template.prototype.boundElement = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return this.element(args.shift(), (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(BoundModel, args, function(){}));
  };

  Gunther.Template.prototype.append = function(element) {
    if (element instanceof Backbone.View) {
      element.render();
      return this.current.append(element.el);
    } else {
      return this.current.append(element);
    }
  };

  Gunther.Template.prototype.itemSubView = function(options, generator) {
    if (generator == null) {
      generator = null;
    }
    return new ItemSubView(options, generator);
  };

  Gunther.Template.prototype.asyncList = function(element, options, generator) {
    var model;
    if (generator == null) {
      generator = null;
    }
    if (options instanceof Backbone.Collection) {
      model = options;
      options = {
        model: model,
        generator: generator
      };
    }
    options.sync = false;
    return this.element(element, function() {
      return new ItemSubView(options);
    });
  };

  Gunther.Template.prototype.syncList = function(element, options, generator) {
    var model;
    if (generator == null) {
      generator = null;
    }
    if (options instanceof Backbone.Collection) {
      model = options;
      options = {
        model: model,
        generator: generator
      };
    }
    options.sync = true;
    return this.element(element, function() {
      return new ItemSubView(options);
    });
  };

  Gunther.Template.prototype.list = Gunther.Template.prototype.syncList;

  ItemSubView = (function(_super) {
    __extends(ItemSubView, _super);

    function ItemSubView() {
      _ref = ItemSubView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    ItemSubView.remove = function(element) {
      return ($(element)).remove();
    };

    ItemSubView.defaultEvents = {
      preRemove: function() {
        return null;
      },
      postRemove: function() {
        return null;
      },
      preInsert: function() {
        return null;
      },
      postInsert: function() {
        return null;
      }
    };

    ItemSubView.generator = new Gunther.IDGenerator;

    ItemSubView.naiveSort = function(collection, parentElement, elementKey) {
      var item, items, _i, _len, _results;
      items = (function() {
        var _i, _len, _ref1, _results;
        _ref1 = collection.toArray();
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          item = _ref1[_i];
          _results.push(item[elementKey].detach());
        }
        return _results;
      })();
      _results = [];
      for (_i = 0, _len = items.length; _i < _len; _i++) {
        item = items[_i];
        _results.push(parentElement.append(item));
      }
      return _results;
    };

    ItemSubView.prototype.initialize = function(options, generator) {
      if (options instanceof Backbone.Collection) {
        this.model = options;
        options = {
          model: options,
          generator: generator
        };
      }
      this.key = "_subview-" + (ItemSubView.generator.generate());
      this.elementKey = "element-" + this.key;
      this.renderedItems = {};
      this._parseOptions(options);
      return this._initEvents();
    };

    ItemSubView.prototype.setElement = function($el) {
      this.$el = $el;
    };

    ItemSubView.prototype.render = function() {
      var _this = this;
      this.model.each(function(item) {
        return _this._initItem(item);
      });
      return this.model.each(function(item) {
        return _this._renderItem(item);
      });
    };

    ItemSubView.prototype._parseOptions = function(options) {
      this.prepend = options.prepend != null ? options.prepend : false;
      if (typeof options.generator === 'function') {
        this.generator = new Gunther.Template(options.generator);
      } else {
        this.generator = options.generator;
      }
      if (!(this.generator instanceof Gunther.Template)) {
        throw new Error("No generator passed");
      }
      this.events = _.extend(ItemSubView.defaultEvents, (options.events != null ? options.events : {}));
      this.remove = options.remove != null ? options.remove : ItemSubView.remove;
      this.evenClass = options.evenClass != null ? options.evenClass : void 0;
      this.oddClass = options.oddClass != null ? options.oddClass : void 0;
      this.sync = options.sync != null ? options.sync : false;
      return this.model = options.collection != null ? options.collection : this.model;
    };

    ItemSubView.prototype._initEvents = function() {
      var _this = this;
      this._addItems = [];
      this._removeItems = [];
      this._checkingQueue = false;
      this.model.bind('add', function(item) {
        return _this._addItemToAddQueue(item);
      });
      this.model.bind('remove', function(item) {
        return _this._addItemToRemoveQueue(item);
      });
      this.model.bind('sort', function() {
        return ItemSubView.naiveSort(_this.model, _this.$el, _this.elementKey);
      });
      return this.model.bind('reset', function(newItems) {
        var item, key, _ref1;
        _ref1 = _this.renderedItems;
        for (key in _ref1) {
          item = _ref1[key];
          _this.removeItem(item);
        }
        return newItems.each(function(item) {
          return _this.addItem(item);
        });
      });
    };

    ItemSubView.prototype._renderItem = function(item) {
      if (item[this.key] instanceof Gunther.Template) {
        item[this.elementKey] = item[this.key].render(item);
      } else if (item[this.key] instanceof Backbone.View) {
        item[this.key].render();
        item[this.elementKey] = item[this.key].el;
      } else {
        throw new Error('Generator must return either a Gunther.Template or a Backbone.View instance');
      }
      this.events.preInsert(item[this.elementKey], this.$el);
      if ((this.evenClass != null) && (this.model.indexOf(item)) % 2 === 0) {
        ($(item[this.elementKey])).addClass(this.evenClass);
      } else if (this.oddClass != null) {
        ($(item[this.elementKey])).addClass(this.oddClass);
      }
      if (this.prepend) {
        this.$el.prependChild(item[this.elementKey]);
      } else {
        ($(this.$el)).append(item[this.elementKey]);
      }
      this.events.postInsert(item[this.elementKey], this.$el);
      return this.renderedItems[item.cid] = item;
    };

    ItemSubView.prototype._removeItem = function(item) {
      if (item[this.key] instanceof Backbone.View) {
        this.events.preRemove(item[this.key]);
        item[this.key].remove();
        this.events.postRemove();
      } else {
        this.events.preRemove(item[this.elementKey]);
        this.remove(item[this.elementKey]);
        this.events.postRemove();
        delete item[this.elementKey];
      }
      return delete this.renderedItems[item.cid];
    };

    ItemSubView.prototype._initItem = function(item) {
      if (typeof this.generator === 'function') {
        return item[this.key] = this.generator(item);
      } else {
        return item[this.key] = this.generator;
      }
    };

    ItemSubView.prototype._addItemToAddQueue = function(item) {
      this._initItem(item);
      this._addItems.push(item);
      return this._addQueueCheck();
    };

    ItemSubView.prototype._addItemToRemoveQueue = function(item) {
      if (item[this.key] == null) {
        return;
      }
      this._removeItems.push(item);
      return this._addQueueCheck();
    };

    ItemSubView.prototype._addQueueCheck = function() {
      var _this = this;
      if (this.sync) {
        return this._checkQueue();
      }
      return Gunther.Helper.animationFrame(function() {
        return _this._checkQueue();
      });
    };

    ItemSubView.prototype._checkQueue = function() {
      var index, item, _i, _j, _len, _len1, _ref1, _ref2;
      if (this._checkingQueue) {
        return;
      }
      this._checkingQueue = true;
      _ref1 = this._addItems;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        item = _ref1[_i];
        this._renderItem.apply(this, [item]);
      }
      _ref2 = this._removeItems;
      for (index = _j = 0, _len1 = _ref2.length; _j < _len1; index = ++_j) {
        item = _ref2[index];
        this._removeItem(item);
      }
      this._addItems = [];
      this._removeItems = [];
      return this._checkingQueue = false;
    };

    return ItemSubView;

  })(Backbone.View);

  Gunther.partials = {};

  Gunther.addPartial = function(key, handler) {
    Gunther.partials[key] = handler;
    if (Gunther.Template.prototype[key] != null) {
      throw new Error("Can not add partial \"" + key + "\", a partial or method with that name already exists");
    }
    return Gunther.Template.prototype[key] = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.partial.apply(this, [key].concat(args));
    };
  };

  Gunther.removePartial = function(key) {
    return delete Gunther.partials.key;
  };

  Gunther.Template.prototype.partial = function() {
    var args, key, template;
    key = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (Gunther.partials[key] == null) {
      throw new Error("Partial \"" + key + "\" does not exist");
    }
    template = new Gunther.Template(Gunther.partials[key]);
    return this.subTemplate.apply(this, [template].concat(args));
  };

  /* Public*/


  Gunther.Template.prototype.attribute = function(name, value) {
    var el;
    el = this.current;
    if (value instanceof BoundProperty) {
      el.attr(name, value.getValue());
      value.bind('change', function(newValue) {
        return el.attr(name, value.getValue());
      });
    } else {
      el.attr(name, value);
    }
    return null;
  };

  Gunther.Template.prototype.boundAttribute = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return this.attribute(args.shift(), (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(BoundProperty, args, function(){}));
  };

  Gunther.Template.prototype.property = function(name, value) {
    var el;
    el = this.current;
    if (value instanceof BoundProperty) {
      el.prop(name, value.getValue());
      value.bind('change', function(newValue) {
        return el.prop(name, value.getValue());
      });
    } else {
      el.prop(name, value);
    }
    return null;
  };

  Gunther.Template.prototype.boundProperty = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return this.property(args.shift(), (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(BoundProperty, args, function(){}));
  };

  Gunther.Template.prototype.css = function(name, value) {
    var el, realName;
    if (name instanceof Object) {
      return (function() {
        var _results;
        _results = [];
        for (realName in name) {
          value = name[realName];
          _results.push(this.css(realName, value));
        }
        return _results;
      }).call(this);
    }
    el = this.current;
    if (value instanceof BoundProperty) {
      el.css(name, value.getValue());
      value.bind('change', function(newValue) {
        return el.css(name, newValue);
      });
      return el;
    } else {
      el.css(name, value);
    }
    return null;
  };

  Gunther.Template.prototype.boundCss = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return this.css(args.shift(), (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(BoundProperty, args, function(){}));
  };

  Gunther.Template.prototype.toggleClass = function(className, model, property, toggle) {
    var element, performToggle, properties, _i, _len;
    properties = [].concat(property);
    if (!(toggle instanceof Function)) {
      toggle = function(value) {
        return value;
      };
    }
    element = this.current;
    performToggle = function(model, value) {
      return ($(element)).toggleClass(className, toggle(value));
    };
    for (_i = 0, _len = properties.length; _i < _len; _i++) {
      property = properties[_i];
      model.on("change:" + property, performToggle);
      performToggle(model, model.get(property));
    }
    return null;
  };

  Gunther.Template.prototype.switchView = function(element, model, properties, generator) {
    return this.element(element, function() {
      return new SwitchedView(this.current, model, properties, generator);
    });
  };

  SwitchedView = (function() {
    SwitchedView.prototype.switches = [];

    function SwitchedView(parent, model, attributeName, generator) {
      var _this = this;
      this.parent = parent;
      this.model = model;
      this.attributeName = attributeName;
      this.model.on("change:" + this.attributeName, function() {
        return _this.render();
      });
      generator.apply(this, [this.model]);
    }

    SwitchedView.prototype.render = function() {
      var _this = this;
      if (this.active != null) {
        this.active.makeUnActiveIn(this.parent);
      }
      this.active = _.find(this.switches, function(viewSwitch) {
        return viewSwitch.isActive(_this.model.get(_this.attributeName));
      });
      return this.active.makeActiveIn(this.parent);
    };

    SwitchedView.prototype.keep = function() {
      var args, template;
      template = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return this.switches.push((function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(ViewSwitch, [ViewSwitch.KEEP, template].concat(__slice.call(args)), function(){}));
    };

    SwitchedView.prototype["switch"] = function() {
      var args, template;
      template = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return this.switches.push((function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(ViewSwitch, [ViewSwitch.SWITCH, template].concat(__slice.call(args)), function(){}));
    };

    return SwitchedView;

  })();

  ViewSwitch = (function() {
    ViewSwitch.KEEP = 'keep';

    ViewSwitch.SWITCH = 'switch';

    ViewSwitch.prototype.isActive = false;

    function ViewSwitch() {
      var args, template, type;
      type = arguments[0], template = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      this.type = type;
      this.template = template;
      this.determinator = args.pop();
      this["arguments"] = args;
    }

    ViewSwitch.prototype.isActive = function(value) {
      return this.determinator(value);
    };

    ViewSwitch.prototype.makeActiveIn = function(element) {
      if (this.switchedElements != null) {
        return this.switchedElements.show();
      } else {
        return this.switchedElements = this.template.renderInto.apply(this.template, [element].concat(this["arguments"]));
      }
    };

    ViewSwitch.prototype.makeUnActiveIn = function(element) {
      if (this.type === ViewSwitch.KEEP) {
        return this.switchedElements.hide();
      } else {
        this.switchedElements.remove();
        return this.switchedElements = null;
      }
    };

    return ViewSwitch;

  })();

  Gunther.SwitchedView = SwitchedView;

  /* Public*/


  Gunther.Template.prototype.text = function(text) {
    var childResult, el;
    el = document.createTextNode('');
    if (typeof text === 'string') {
      el.nodeValue = text;
    } else {
      childResult = Gunther.Template.elementValue(text, this);
      if (childResult instanceof BoundProperty) {
        el.nodeValue = childResult.getValue();
        childResult.bind('change', function(newVal) {
          return el.nodeValue = newVal;
        });
      } else {
        el.nodeValue = childResult;
      }
    }
    return this.current.append(el);
  };

  Gunther.Template.prototype.boundText = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return this.text((function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(BoundProperty, args, function(){}));
  };

  Gunther.Template.prototype.spacedText = function(text) {
    return this.text(" " + text + " ");
  };

  Gunther.View = (function(_super) {
    __extends(View, _super);

    function View() {
      _ref1 = View.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    View.wrapTemplate = function(tpl) {
      if (typeof tpl === 'function') {
        return new Gunther.Template(tpl);
      } else {
        return tpl;
      }
    };

    View.prototype.render = function() {
      var template;
      template = Gunther.View.wrapTemplate(this.template);
      if (!(template instanceof Gunther.Template)) {
        throw new Error("No template given");
      }
      return template.renderInto(this.$el);
    };

    return View;

  })(Backbone.View);

  Gunther.html5Tags = ["a", "abbr", "address", "area", "article", "aside", "audio", "b", "base", "bdi", "bdo", "blockquote", "body", "br", "button", "canvas", "caption", "cite", "code", "col", "colgroup", "data", "datagrid", "datalist", "dd", "del", "details", "dfn", "dialog", "div", "dl", "dt", "em", "embed", "eventsource", "fieldset", "figcaption", "figure", "footer", "form", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "hr", "html", "i", "iframe", "img", "input", "ins", "kbd", "keygen", "label", "legend", "li", "link", "main", "mark", "map", "menu", "menuitem", "meta", "meter", "nav", "noscript", "object", "ol", "optgroup", "option", "output", "p", "param", "pre", "progress", "q", "ruby", "rp", "rt", "s", "samp", "script", "section", "select", "small", "source", "span", "strong", "style", "sub", "summary", "sup", "table", "tbody", "td", "textarea", "tfoot", "th", "thead", "time", "title", "tr", "track", "u", "ul", "var", "video", "wbr"];

  _ref2 = Gunther.html5Tags;
  _fn = function(tag) {
    return Gunther.addPartial(tag, function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.element.apply(this, [tag].concat(args));
    });
  };
  for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
    tag = _ref2[_i];
    _fn(tag);
  }

}).call(this);

/*
//@ sourceMappingURL=gunther.mapped.js.map
*/