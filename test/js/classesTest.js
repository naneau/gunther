(function() {
  ({
    module: 'Classes'
  });

  test('Initializing', function() {
    var elem;
    elem = singleElement('div', 'div.foo');
    equal(elem.hasClass('foo'), true, 'Single class should be added');
    equal(elem.attr('class'), 'foo', 'Only specified classes should be added');
    elem = singleElement('div', 'div.foo.bar');
    equal(elem.hasClass('foo'), true, 'Multiple classes should be added');
    equal(elem.hasClass('bar'), true, 'Multiple classes should be added');
    equal(elem.hasClass('bar'), true, 'Multiple classes should be added');
    equal(elem.attr('class'), 'foo bar', 'Only specified classes should be added');
    elem = singleElement('div', function() {
      return this.element('div.foo', function() {
        return this.attr('class', 'bar');
      });
    });
    equal(elem.hasClass('foo'), false, 'Class can be overwritten');
    return equal(elem.hasClass('bar'), true, 'Class can be overwritten');
  });

  test('Toggling', function() {
    var elem, model;
    model = new Backbone.Model({
      bar: true
    });
    elem = singleElement('div', function() {
      return this.element('div.foo', function() {
        return this.toggleClass('bar', model, 'bar');
      });
    });
    equal(elem.hasClass('foo'), true, '@toggleClass shouldn\'t remove default class');
    equal(elem.hasClass('bar'), true, '@toggleClass should initialize its class right');
    model = new Backbone.Model({
      bar: false
    });
    elem = singleElement('div', function() {
      return this.element('div.foo', function() {
        return this.toggleClass('bar', model, 'bar');
      });
    });
    equal(elem.hasClass('foo'), true, '@toggleClass shouldn\'t remove default class');
    equal(elem.hasClass('bar'), false, '@toggleClass should initialize its class right');
    model.set({
      bar: true
    });
    equal(elem.hasClass('bar'), true, '@toggleClass should add its class');
    model.set({
      bar: false
    });
    return equal(elem.hasClass('bar'), false, '@toggleClass should remove its class');
  });

}).call(this);
