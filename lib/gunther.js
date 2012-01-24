(function() {
  var BoundProperty, Gunther, ItemSubView, htmlElement, _fn, _i, _len, _ref,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  Gunther = {};

  if ((typeof require) != null) {
    module.exports = Gunther;
  } else {
    window.Gunther = Gunther;
  }

  Gunther.IDGenerator = (function() {

    function IDGenerator() {
      this.value = 0;
    }

    IDGenerator.prototype.generate = function() {
      return this.value++;
    };

    return IDGenerator;

  })();

  Gunther.HTML = (function() {

    function HTML() {}

    HTML.elements = ["a", "abbr", "address", "article", "aside", "audio", "b", "bdi", "bdo", "blockquote", "body", "button", "canvas", "caption", "cite", "code", "colgroup", "datalist", "dd", "del", "details", "dfn", "div", "dl", "dt", "em", "fieldset", "figcaption", "figure", "footer", "form", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup", "html", "i", "iframe", "ins", "kbd", "label", "legend", "li", "map", "mark", "menu", "meter", "nav", "noscript", "object", "ol", "optgroup", "option", "output", "p", "pre", "progress", "q", "rp", "rt", "ruby", "s", "samp", "script", "section", "select", "small", "span", "strong", "style", "sub", "summary", "sup", "table", "tbody", "td", "textarea", "tfoot", "th", "thead", "time", "title", "tr", "u", "ul", "video", "area", "base", "br", "col", "command", "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source", "track", "wbr", "applet", "acronym", "bgsound", "dir", "frameset", "noframes", "isindex", "listing", "nextid", "noembed", "plaintext", "rb", "strike", "xmp", "big", "blink", "center", "font", "marquee", "multicol", "nobr", "spacer", "tt", "basefont", "frame", "date"];

    HTML.eventNames = ['load', 'unload', 'blur', 'change', 'focus', 'reset', 'select', 'submit', 'abort', 'keydown', 'keyup', 'keypress', 'click', 'dblclick', 'mousedown', 'mouseout', 'mouseover', 'mouseup'];

    return HTML;

  })();

  BoundProperty = (function() {

    function BoundProperty(model, propertyNames, valueGenerator) {
      var propertyName, _i, _len, _ref,
        _this = this;
      this.model = model;
      this.propertyNames = propertyNames;
      this.valueGenerator = valueGenerator;
      if (!(this.valueGenerator != null) && typeof this.propertyNames === 'string') {
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

    return BoundProperty;

  })();

  _.extend(BoundProperty.prototype, Backbone.Events);

  ItemSubView = (function(_super) {

    __extends(ItemSubView, _super);

    function ItemSubView() {
      ItemSubView.__super__.constructor.apply(this, arguments);
    }

    ItemSubView.generator = new Gunther.IDGenerator;

    ItemSubView.prototype.initialize = function(options) {
      var _this = this;
      this.key = "_subview-" + (ItemSubView.generator.generate());
      this.elementKey = "element-" + this.key;
      this.prepend = options.prepend != null ? options.prepend : false;
      this.generator = options.generator;
      this.model.each(function(item) {
        return _this.initItem(item);
      });
      this.model.bind('add', function(item) {
        _this.initItem(item);
        return _this.renderItem(item);
      });
      return this.model.bind('remove', function(item) {
        if (!(item[_this.key] != null)) return;
        if (item[_this.key] instanceof Backbone.View) {
          return item[_this.key].remove();
        } else {
          return item[_this.elementKey].remove();
        }
      });
    };

    ItemSubView.prototype.initItem = function(item) {
      return item[this.key] = this.generator(item);
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
      if (this.prepend) {
        return this.el.prepend(item[this.elementKey]);
      } else {
        return this.el.append(item[this.elementKey]);
      }
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

    Template.createHtmlElement = function(tagName) {
      return $(document.createElement(tagName));
    };

    Template.addAttributes = function(el, attributes) {
      var attribute, attributeName, attributeValue, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = attributes.length; _i < _len; _i++) {
        attribute = attributes[_i];
        _results.push((function() {
          var _results2;
          _results2 = [];
          for (attributeName in attribute) {
            attributeValue = attribute[attributeName];
            _results2.push((function(attributeName, attributeValue) {
              if (_.include(Gunther.HTML.eventNames, attributeName)) {
                return el.bind(attributeName, function() {
                  var args;
                  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                  return attributeValue.apply(null, args);
                });
              } else if (attributeValue instanceof BoundProperty) {
                el.attr(attributeName, attributeValue.getValue());
                return attributeValue.bind('change', function(newValue) {
                  return el.attr(attributeName, newValue);
                });
              } else {
                return el.attr(attributeName, attributeValue);
              }
            })(attributeName, attributeValue));
          }
          return _results2;
        })());
      }
      return _results;
    };

    Template.generateChildren = function(el, childFn, scope) {
      var childResult;
      childResult = childFn.apply(scope);
      if (typeof childResult !== 'object') {
        el.append(document.createTextNode(childResult));
      }
      if (childResult instanceof BoundProperty) {
        el.html(childResult.getValue());
        return childResult.bind('change', function(newVal) {
          return el.html(newVal);
        });
      } else if (childResult instanceof Backbone.View) {
        childResult.el = el;
        return childResult.render();
      }
    };

    function Template(fn) {
      this.fn = fn;
      null;
    }

    Template.prototype.render = function() {
      var args, child, children, domParser, _i, _j, _len, _len2, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.root = $('<div />');
      this.current = this.root;
      this.fn.apply(this, args);
      children = this.root.children();
      _ref = Gunther.Template.domParsers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        domParser = _ref[_i];
        for (_j = 0, _len2 = children.length; _j < _len2; _j++) {
          child = children[_j];
          domParser(child);
        }
      }
      return children;
    };

    Template.prototype.renderInto = function() {
      var args, child, el, _i, _len, _ref;
      el = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _ref = this.render.apply(this, args);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        el.append(child);
      }
      return new Backbone.View({
        el: el
      });
    };

    Template.prototype.text = function(text) {
      var childResult, el;
      el = document.createTextNode('');
      if (typeof text === 'string') {
        el.nodeValue = text;
      } else {
        if (typeof text === 'function') childResult = text.apply(this);
        if (childResult instanceof BoundProperty) {
          el.nodeValue = childResult.getValue();
          childResult.bind('change', function(newVal) {
            return el.nodeValue = newVal;
          });
        }
      }
      return this.current.append(el);
    };

    Template.prototype.addElement = function() {
      var args, current, el, tagName;
      tagName = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      current = this.current;
      el = Gunther.Template.createHtmlElement(tagName);
      this.current = el;
      if (typeof args[args.length - 1] === 'function') {
        Gunther.Template.generateChildren(el, args.pop(), this);
      }
      Gunther.Template.addAttributes(el, args);
      current.append(el);
      this.current = current;
      return null;
    };

    Template.prototype.bind = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(BoundProperty, args, function() {});
    };

    Template.prototype.itemSubView = function(options) {
      return new ItemSubView(options);
    };

    Template.prototype.e = function() {
      var args, tagName;
      tagName = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return this.addElement.apply(this, [tagName].concat(__slice.call(args)));
    };

    Template.prototype.t = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.text.apply(this, args);
    };

    return Template;

  })();

  _ref = Gunther.HTML.elements;
  _fn = function(htmlElement) {
    return Gunther.Template.prototype[htmlElement] = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.addElement.apply(this, [htmlElement].concat(__slice.call(args)));
    };
  };
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    htmlElement = _ref[_i];
    _fn(htmlElement);
  }

}).call(this);
