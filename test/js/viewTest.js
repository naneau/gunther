(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  module('View');

  test('rendering', function() {
    var TestView, t, wrapper, _ref;
    TestView = (function(_super) {
      __extends(TestView, _super);

      function TestView() {
        _ref = TestView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      TestView.prototype.template = function() {
        this.div('foo');
        this.p('foo');
        return this.a('foo');
      };

      return TestView;

    })(Gunther.View);
    t = new TestView;
    wrapper = renderGuntherView(t);
    equal(wrapper.children().length, 3, 'Root elements should render in correct number');
    equal(wrapper.children()[0].tagName, 'DIV', 'Element should render as correct type');
    equal(wrapper.children()[1].tagName, 'P', 'Element should render as correct type');
    return equal(wrapper.children()[2].tagName, 'A', 'Element should render as correct type');
  });

}).call(this);
