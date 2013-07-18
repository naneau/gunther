(function() {
  var ExampleView, ItemView, _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  ExampleView = (function(_super) {
    __extends(ExampleView, _super);

    function ExampleView() {
      _ref = ExampleView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    ExampleView.template = new Gunther.Template(function(collection) {
      this.e('div', function() {
        this.e('a', function() {
          this.on('click', function(e) {
            return collection.add(new ExampleModel);
          });
          return this.text('Add an item ');
        });
        this.e('a', function() {
          this.on('click', function(e) {
            return collection.removeRandom();
          });
          return this.text('Remove a random item ');
        });
        this.e('a', function() {
          this.on('click', function(e) {
            collection.sortVar = 'index';
            return collection.sort();
          });
          return this.text('Sort by index ');
        });
        return this.e('a', function() {
          this.on('click', function(e) {
            collection.sortVar = 'value';
            return collection.sort();
          });
          return this.text('Sort by value ');
        });
      });
      return this.e('div', function() {
        return this.itemSubView({
          model: collection,
          generator: function(item) {
            return new Gunther.Template(function() {
              return this.e('div', "This is item " + (item.get('index')) + ", with value " + (item.get('value')));
            });
          }
        });
      });
    });

    ExampleView.prototype.render = function() {
      return ExampleView.template.renderInto(this.el, this.model);
    };

    return ExampleView;

  })(Backbone.View);

  window.ExampleView = ExampleView;

  ItemView = (function(_super) {
    __extends(ItemView, _super);

    function ItemView() {
      _ref1 = ItemView.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    ItemView.template = new Gunther.Template(function(item) {
      return this.section({
        id: "item-" + (item.get('index'))
      }, function() {
        this.h1(function() {
          return item.get('text');
        });
        this.h2(function() {
          return "Item number " + (item.get('index'));
        });
        return this.p(function() {
          return this.bind(item, 'autoUpdated', function() {
            return "This element was updated " + (item.get('autoUpdated')) + " times";
          });
        });
      });
    });

    ItemView.prototype.render = function() {
      return ItemView.template.renderInto(this.el, this.model);
    };

    return ItemView;

  })(Backbone.View);

}).call(this);

/*
//@ sourceMappingURL=subviews.js.map
*/