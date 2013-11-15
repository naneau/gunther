(function() {
  test('Properties', function() {
    var elem;
    elem = singleElement('input', 'input[type=checkbox]:checked');
    equal(elem.prop('checked'), true, 'Properties should be set from description');
    elem = singleElement('input', function() {
      return this.element('input[type=checkbox]', function() {
        return this.property('checked', true);
      });
    });
    equal(elem.prop('checked'), true, 'Properties should be set from @property');
    elem = singleElement('input', function() {
      return this.element('input[type=checkbox]', function() {
        return this.property('checked', false);
      });
    });
    return equal(elem.prop('checked'), false, 'Properties should be set from @property');
  });

  test('Properties, bound', function() {
    var elem, model;
    model = new Backbone.Model({
      foo: false
    });
    elem = singleElement('input', model, function() {
      return this.element('input[type=checkbox]', function() {
        return this.boundProperty('checked', model, 'foo');
      });
    });
    equal(elem.prop('checked'), false, 'Properties should be initialized right from @boundProperty');
    model.set({
      foo: true
    });
    return equal(elem.prop('checked'), true, 'Properties should change with @boundProperty');
  });

}).call(this);
