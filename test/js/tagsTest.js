(function() {
  module('Initialization');

  test('tags', function() {
    var wrapper;
    wrapper = renderGunther(new Gunther.Template(function() {
      this.div('foo');
      this.p('foo');
      return this.a('foo');
    }));
    equal(wrapper.children().length, 3, 'Root elements should render in correct number');
    equal(wrapper.children()[0].tagName, 'DIV', 'Element should render as correct type');
    equal(wrapper.children()[0].innerHTML, 'foo', 'Element should get text');
    equal(wrapper.children()[1].tagName, 'P', 'Element should render as correct type');
    return equal(wrapper.children()[2].tagName, 'A', 'Element should render as correct type');
  });

}).call(this);
