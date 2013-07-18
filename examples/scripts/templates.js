(function() {
  var View, bindings, events, styleProperties, subTemplate, subTemplates, text, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  text = new Gunther.Template(function(model) {
    this.e('p', 'this is just a text node');
    return this.e('div', function() {
      this.prop('class', 'foo');
      this.e('p', 'a child node that is text');
      return this.e('p', model.get('textProperty'));
    });
  });

  events = new Gunther.Template(function(model) {
    return this.e('a', function() {
      this.on('click', function(event) {
        event.stopPropagation();
        return alert('Clickity');
      });
      return this.text('the text for this node');
    });
  });

  bindings = new Gunther.Template(function(model) {
    this.e('p', this.bind(model, 'propertyName'));
    this.e('div', function() {
      return this.prop('class', this.bind(model, 'propertyName', function(newValue) {
        if (newValue === 'x') {
          return 'class-for-x';
        } else {
          return 'class-for-not-x';
        }
      }));
    });
    return this.e('input', function() {
      return this.prop('value', this.doubleBind(model, 'propertyName'));
    });
  });

  styleProperties = new Gunther.Template(function(model) {
    return this.e('div', function() {
      return this.boundStyle('display', model, 'propertyName', function(newValue, element) {
        if (newValue === 'awesome') {
          return 'block';
        } else {
          return 'none';
        }
      });
    });
  });

  subTemplates = new Gunther.Template(function(collection) {
    return this.e('ul', this.collection(collection, subTemplate));
  });

  subTemplate = new Gunther.Template(function(model) {
    return this.e('li', model.get('textProperty'));
  });

  View = (function(_super) {
    __extends(View, _super);

    function View() {
      _ref = View.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    View.prototype.initialize = function() {
      return this.model = new Backbone.Model;
    };

    View.prototype.render = function() {
      return template.renderInto(this.el, this.model);
    };

    return View;

  })(new Backbone.View);

}).call(this);

/*
//@ sourceMappingURL=templates.js.map
*/