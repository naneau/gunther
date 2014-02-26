(function() {
  module('Elements');

  test('Rendering', function() {
    var elem, wrapper;
    elem = singleElement('div', 'div');
    equal(elem[0].tagName, 'DIV', 'Element should render as correct type');
    equal(elem.contents().length, 0, 'Empty element should be empty');
    elem = singleElement('p', 'p');
    equal(elem[0].tagName, 'P', 'Element should render as correct type');
    equal(elem.contents().length, 0, 'Empty element should be empty');
    elem = singleElement('div', function() {
      return this.element('div', function() {
        return this.text('foo');
      });
    });
    equal(elem[0].tagName, 'DIV', 'Element should render as correct type');
    equal(elem.contents().length, 1, 'Non empty element should be not empty');
    equal(elem.contents().first().text(), 'foo', 'Text should render inside of an element');
    wrapper = renderGunther(new Gunther.Template(function() {
      this.element('div');
      this.element('div');
      return this.element('div');
    }));
    equal(wrapper.children().length, 3, 'Root elements should render in correct number');
    equal(wrapper.children()[0].tagName, 'DIV', 'Element should render as correct type');
    equal(wrapper.children()[1].tagName, 'DIV', 'Element should render as correct type');
    return equal(wrapper.children()[2].tagName, 'DIV', 'Element should render as correct type');
  });

  test('Children', function() {
    var elem;
    elem = singleElement('div', function() {
      return this.element('div', function() {
        this.element('div');
        this.element('p');
        this.element('span');
        this.text('foo');
        return this.element('div');
      });
    });
    equal(elem[0].tagName, 'DIV', 'Element should render as correct type');
    equal(elem.contents().length, 5, 'There should be five children');
    equal(elem.contents()[0].tagName, 'DIV', 'Children should be of correct type');
    equal(elem.contents()[1].tagName, 'P', 'Children should be of correct type');
    equal(elem.contents()[2].tagName, 'SPAN', 'Children should be of correct type');
    equal(elem.contents()[3].nodeValue, 'foo', 'Text should render next to children');
    return equal(elem.contents()[4].tagName, 'DIV', 'Children should be of correct type');
  });

  test('Children of children', function() {
    var elem;
    elem = singleElement('div', function() {
      return this.element('div', function() {
        this.element('section', function() {
          return this.element('span', function() {
            return 'foo';
          });
        });
        return this.element('p', function() {
          return this.element('a[foo=bar]');
        });
      });
    });
    equal(elem[0].tagName, 'DIV', 'Element should render as correct type');
    equal(elem.find('> section,p').length, 2, 'There should be two children');
    equal(elem.find('> section > span').length, 1, 'Children of children should be of correct type');
    return equal(elem.find('> p > a').length, 1, 'Children of children should be of correct type');
  });

}).call(this);
