(function() {
  var ExampleView, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ExampleView = (function(_super) {
    __extends(ExampleView, _super);

    function ExampleView() {
      _ref = ExampleView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    ExampleView.template = new Gunther.Template(function(model) {
      return this.e('section', function() {
        this.attribute('class', 'test');
        this.e('h1', 'Basic Example');
        this.e('p', 'Text from a template');
        this.e('p', model.get('text'));
        this.e('p', this.bind(model, 'autoUpdated'));
        this.e('p', this.bind(model, 'autoUpdated', function(newValue) {
          return "This string was interpolated " + (model.get('autoUpdated')) + " times";
        }));
        return this.e('br');
      });
    });

    ExampleView.prototype.render = function() {
      return ExampleView.template.renderInto(this.el, this.model);
    };

    return ExampleView;

  })(Backbone.View);

  window.ExampleView = ExampleView;

}).call(this);

/*
//@ sourceMappingURL=basic.js.map
*/