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
        this.e('h1', 'Events');
        return this.e('div', function() {
          this.on('click', function(e) {
            return model.set('foo', (model.get('foo')) + 1);
          });
          return this.text(this.bind(model, 'foo', function() {
            return "I was clicked " + (model.get('foo')) + " times";
          }));
        });
      });
    });

    ExampleView.prototype.initialize = function() {
      return this.model = new Backbone.Model({
        foo: 0
      });
    };

    ExampleView.prototype.render = function() {
      return ExampleView.template.renderInto(this.el, this.model);
    };

    return ExampleView;

  })(Backbone.View);

  window.ExampleView = ExampleView;

}).call(this);

/*
//@ sourceMappingURL=events.js.map
*/