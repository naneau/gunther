(function() {
  test('Attributes', function() {
    var elem;
    elem = singleElement('div', 'div[foo=bar]');
    equal(elem.attr('foo'), 'bar', 'Attributes should be set');
    return equal(elem.contents().length, 0, 'There should not be content in an empty node');
  });

  test('Bound attributes', function() {
    var elem, model;
    model = new Backbone.Model;
    model.set('foo', 'bar');
    elem = singleElement('div', function() {
      return this.element('div', function() {
        return this.boundAttribute('foo', model, 'foo');
      });
    });
    equal(elem.attr('foo'), 'bar', 'Attributes should be set');
    equal(elem.contents().length, 0, 'There should not be content in an empty node');
    model.set('foo', 'baz');
    return equal(elem.attr('foo'), 'baz', 'Attributes should change when the underlying model does');
  });

}).call(this);
