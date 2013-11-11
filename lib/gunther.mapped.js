(function() {
  var Backbone, BoundModel, BoundProperty, Gunther, ItemSubView, _, _ref,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Gunther = {
    partials: {},
    addPartial: function(key, partial) {
      return Gunther.partials[key] = partial;
    }
  };

  if (typeof require !== "undefined" && require !== null) {
    module.exports = Gunther;
    _ = require('underscore');
    Backbone = require('backbone');
  } else {
    window.Gunther = Gunther;
    _ = window._, Backbone = window.Backbone;
  }

  if ((typeof _) === !'function') {
    throw 'Underscore.js must be loaded for Gunther to work';
  }

  Gunther.Helper = (function() {
    function Helper() {}

    Helper.createHtmlElement = function(description) {
      var attributeDefinition, element, tagName, token, tokens, _i, _len;
      tokens = description.split(/(?=\.)|(\[.+\=.+\])|(?=#)/);
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
        if (token == null) {
          continue;
        }
        if (token[0] === '#') {
          element.attr('id', token.substr(1));
        } else if (token[0] === '.') {
          element.attr('class', (element.attr('class')) + ' ' + token.substr(1));
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
      if (this.template instanceof Function && !(this.template instanceof Gunther.Template)) {
        this.template = new Gunther.Template(this.template);
      }
      this.currentCid = this.model.cid;
      this.model.bind("change:" + this.propertyName, function(parent) {
        model = parent.get(_this.propertyName);
        if ((model != null) && model.cid === _this.currentCid) {
          return;
        }
        if (model != null) {
          _this.currentCid = model.cid;
        } else {
          _this.currentCid = null;
        }
        return _this.trigger('change', model);
      });
    }

    BoundModel.prototype.getValueInEl = function(el) {
      return this.template.renderInto.apply(this.template, [].concat(el, this.model.get(this.propertyName), this.args));
    };

    return BoundModel;

  })();

  _.extend(BoundModel.prototype, Backbone.Events);

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
      var _this = this;
      if (options instanceof Backbone.Collection) {
        this.model = options;
        options = {
          model: options,
          generator: generator
        };
      }
      this.key = "_subview-" + (ItemSubView.generator.generate());
      this.elementKey = "element-" + this.key;
      this.prepend = options.prepend != null ? options.prepend : false;
      this.generator = options.generator;
      this.events = _.extend(ItemSubView.defaultEvents, (options.events != null ? options.events : {}));
      this.remove = options.remove != null ? options.remove : ItemSubView.remove;
      this.evenClass = options.evenClass != null ? options.evenClass : void 0;
      this.oddClass = options.oddClass != null ? options.oddClass : void 0;
      this.renderedItems = {};
      this.model = options.collection != null ? options.collection : this.model;
      this.model.each(function(item) {
        return _this.initItem(item);
      });
      this.model.bind('add', function(item) {
        return _this.addItem(item);
      });
      this.model.bind('remove', function(item) {
        return _this.removeItem(item);
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

    ItemSubView.prototype.setElement = function($el) {
      this.$el = $el;
    };

    ItemSubView.prototype.addItem = function(item) {
      this.initItem(item);
      return this.renderItem(item);
    };

    ItemSubView.prototype.removeItem = function(item) {
      if (item[this.key] == null) {
        return;
      }
      if (item[this.key] instanceof Backbone.View) {
        this.events.preRemove(item[this.key]);
        item[this.key].remove();
        this.events.postRemove();
      } else {
        this.events.preRemove(item[this.elementKey]);
        this.remove(item[this.elementKey]);
        this.events.postRemove();
      }
      return delete this.renderedItems[item.cid];
    };

    ItemSubView.prototype.initItem = function(item) {
      if (typeof this.generator === 'function') {
        return item[this.key] = this.generator(item);
      } else {
        return item[this.key] = this.generator;
      }
    };

    ItemSubView.prototype.renderItem = function(item) {
      if (item[this.key] instanceof Gunther.Template) {
        item[this.elementKey] = item[this.key].render(item);
      } else if (item[this.key] instanceof Backbone.View) {
        item[this.key].render();
        item[this.elementKey] = item[this.key].el;
      } else {
        throw new Error('Generator must return either a Gunther.Template or a Backbone.View instance');
      }
      this.events.preInsert(item[this.elementKey], this.$el);
      if ((this.model.indexOf(item)) % 2 === 0) {
        item[this.elementKey].addClass(this.evenClass);
      } else {
        item[this.elementKey].addClass(this.oddClass);
      }
      if (this.prepend) {
        this.$el.prepend(item[this.elementKey]);
      } else {
        this.$el.append(item[this.elementKey]);
      }
      this.events.postInsert(item[this.elementKey], this.$el);
      return this.renderedItems[item.cid] = item;
    };

    ItemSubView.prototype.render = function() {
      var _this = this;
      return this.model.each(function(item) {
        return _this.renderItem(item);
      });
    };

    return ItemSubView;

  })(Backbone.View);

  Gunther.Template = (function() {
    Template.domParsers = [];

    Template.removePartial = function(key) {
      return delete Gunther.Template.partials.key;
    };

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
      var args, child, children, domParser, _i, _j, _len, _len1, _ref1;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.root = $('<div />');
      this.current = this.root;
      this.fn.apply(this, args);
      children = this.root.children();
      _ref1 = Gunther.Template.domParsers;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        domParser = _ref1[_i];
        for (_j = 0, _len1 = children.length; _j < _len1; _j++) {
          child = children[_j];
          domParser(child);
        }
      }
      return children;
    };

    Template.prototype.renderInto = function() {
      var args, child, el, _i, _len, _ref1;
      el = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _ref1 = this.render.apply(this, args);
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        child = _ref1[_i];
        ($(el)).append(child);
      }
      return new Backbone.View({
        el: $(el)
      });
    };

    Template.prototype.text = function(text) {
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

    Template.prototype.boundText = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.text((function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(BoundProperty, args, function(){}));
    };

    Template.prototype.spacedText = function(text) {
      return this.text(" " + text + " ");
    };

    Template.prototype.element = function() {
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

    Template.prototype.boundElement = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.element(args.shift(), (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(BoundModel, args, function(){}));
    };

    Template.prototype.attribute = function() {
      var args, el, name, value;
      name = arguments[0], value = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      el = this.current;
      if (value instanceof BoundProperty) {
        el.attr(name, value.getValue());
        return value.bind('change', function(newValue) {
          return el.attr(name, value.getValue());
        });
      } else {
        return el.attr(name, value);
      }
    };

    Template.prototype.boundAttribute = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.attribute(args.shift(), (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(BoundProperty, args, function(){}));
    };

    Template.prototype.property = function() {
      var args, el, name, value;
      name = arguments[0], value = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      el = this.current;
      if (value instanceof BoundProperty) {
        el.prop(name, value.getValue());
        return value.bind('change', function(newValue) {
          return el.prop(name, value.getValue());
        });
      } else {
        return el.prop(name, value);
      }
    };

    Template.prototype.boundProperty = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.property(args.shift(), (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(BoundProperty, args, function(){}));
    };

    Template.prototype.css = function(name, value) {
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
        return el.css(name, value);
      }
    };

    Template.prototype.boundCss = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.css(args.shift(), (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return Object(result) === result ? result : child;
      })(BoundProperty, args, function(){}));
    };

    Template.prototype.show = function(model, properties, resolver) {
      var element, property, show, _i, _len, _ref1, _results,
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
      _ref1 = [].concat(properties);
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        property = _ref1[_i];
        _results.push((function(property) {
          model.on("change:" + property, function(model) {
            return show(element, resolver(model.get(property)));
          });
          return show(element, resolver(model.get(property)));
        })(property));
      }
      return _results;
    };

    Template.prototype.hide = function(model, properties, resolver) {
      if (resolver == null) {
        resolver = function(value) {
          return value;
        };
      }
      return this.show(model, properties, function(value) {
        return !resolver(value);
      });
    };

    Template.prototype.toggleClass = function(className, model, properties, toggle) {
      var element, performToggle, property, _i, _len, _results;
      properties = [].concat(properties);
      if (!(toggle instanceof Function)) {
        toggle = function(value) {
          return value;
        };
      }
      element = this.current;
      performToggle = function(model, value) {
        return ($(element)).toggleClass(className, toggle(value));
      };
      _results = [];
      for (_i = 0, _len = properties.length; _i < _len; _i++) {
        property = properties[_i];
        model.on("change:" + property, performToggle);
        _results.push(performToggle(model, model.get(property)));
      }
      return _results;
    };

    Template.prototype.on = function(event, handler) {
      return this.current.bind(event, handler);
    };

    Template.prototype.haltedOn = function(event, handler) {
      return this.current.bind(event, function(event) {
        event.stopPropagation();
        event.preventDefault();
        return handler(event);
      });
    };

    Template.prototype.append = function(element) {
      if (element instanceof Backbone.View) {
        element.render();
        return this.current.append(element.el);
      } else {
        return this.current.append(element);
      }
    };

    Template.prototype.subTemplate = function() {
      var args, template;
      template = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return template.renderInto.apply(template, [this.current].concat(__slice.call(args)));
    };

    Template.prototype.partial = function() {
      var args, key, template;
      key = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (Gunther.partials[key] == null) {
        throw new Error("Partial \"" + key + "\" does not exist");
      }
      template = new Gunther.Template(Gunther.partials[key]);
      return this.subTemplate.apply(this, [template].concat(args));
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

    Template.prototype.itemSubView = function(options, view) {
      if (view == null) {
        view = null;
      }
      return new ItemSubView(options, view);
    };

    Template.prototype.list = function(element, options, view) {
      if (view == null) {
        view = null;
      }
      return this.element(element, function() {
        return new ItemSubView(options, view);
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

    Template.prototype.a = function() {
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

    Template.prototype.p = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.partial.apply(this, args);
    };

    return Template;

  })();

}).call(this);

/*
//@ sourceMappingURL=gunther.mapped.js.map
*/