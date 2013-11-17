(function() {
  test('Bound elements', function() {
    var boundElement, elem, model, template, wrapper;
    model = new Backbone.Model({
      "class": 'foo'
    });
    template = new Gunther.Template(function(model) {
      this.element('div.before');
      this.boundElement('div.wrapper', model, 'class', function() {
        return this.element("div." + (model.get('class')));
      });
      return this.element('div.after');
    });
    wrapper = renderGunther(template, model);
    equal(wrapper.find('> div').length, 3, 'Bound element should render among siblings');
    boundElement = wrapper.find('.wrapper');
    equal(boundElement.children('.foo').length, 1, 'Bound element should initialize');
    model.set('class', 'bar');
    elem = deepEqual(wrapper.find('.wrapper'), boundElement, 'Parent element should not change');
    return equal(boundElement.children('.bar').length, 1, 'Bound element should change');
  });

}).call(this);
