(function() {
  var ExampleCollection, ExampleModel, _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ExampleModel = (function(_super) {
    __extends(ExampleModel, _super);

    function ExampleModel() {
      _ref = ExampleModel.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    ExampleModel.prototype.initialize = function() {
      var _this = this;
      this.set({
        text: 'This is some text...',
        autoUpdated: 0
      });
      return setInterval((function() {
        return _this.update();
      }), 1000);
    };

    ExampleModel.prototype.update = function() {
      return this.set({
        autoUpdated: (this.get('autoUpdated')) + 1
      });
    };

    return ExampleModel;

  })(Backbone.Model);

  ExampleCollection = (function(_super) {
    __extends(ExampleCollection, _super);

    function ExampleCollection() {
      _ref1 = ExampleCollection.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    ExampleCollection.prototype.model = ExampleModel;

    ExampleCollection.prototype.initialize = function() {
      var x, _i, _results,
        _this = this;
      this.index = 0;
      this.bind('add', function(item) {
        return item.set({
          index: _this.index++,
          value: Math.round(Math.random() * 100)
        });
      });
      _results = [];
      for (x = _i = 0; _i <= 10; x = ++_i) {
        _results.push(this.add(new ExampleModel));
      }
      return _results;
    };

    ExampleCollection.prototype.sortVar = 'index';

    ExampleCollection.prototype.comparator = function(item) {
      return item.get(this.sortVar);
    };

    ExampleCollection.prototype.removeRandom = function() {
      if (this.size() === 0) {
        return;
      }
      return this.remove(this.at(Math.floor(Math.random() * this.size())));
    };

    return ExampleCollection;

  })(Backbone.Collection);

  window.ExampleModel = ExampleModel;

  window.ExampleCollection = ExampleCollection;

}).call(this);

/*
//@ sourceMappingURL=models.js.map
*/