(function() {
  test('Switch views', function() {
    var state, template, templateKeep, templateSwitch, wrapper;
    templateKeep = new Gunther.Template(function() {
      return this.element('div.kept', function() {
        return 'I am kept';
      });
    });
    templateSwitch = new Gunther.Template(function() {
      return this.element('div.switch', function() {
        return 'I am switched';
      });
    });
    template = new Gunther.Template(function(state) {
      return this.switchView('div.switched-wrapper', state, 'toggle', function() {
        this.keep(templateKeep, state, function(toggle) {
          return toggle;
        });
        return this["switch"](templateSwitch, state, function(toggle) {
          return !toggle;
        });
      });
    });
    state = new Backbone.Model({
      toggle: true
    });
    wrapper = renderGunther(template, state);
    equal((wrapper.find('.switched-wrapper')).length, 1, 'Switched view should initialize its wrapping element');
    equal((wrapper.find('div.kept')).length, 1, 'Switched view should initialize with the right elements');
    equal((wrapper.find('div.switch')).length, 0, 'Switched view should initialize with the right elements');
    state.set('toggle', false);
    equal((wrapper.find('div.kept')).length, 1, 'Switched view should keep elements');
    ok(!(wrapper.find('div.kept')).is(':visible'), 'Switched view should hide elements that it keeps');
    equal((wrapper.find('div.switch')).length, 1, 'Switched view should render new elements');
    state.set('toggle', true);
    equal((wrapper.find('div.kept')).length, 1, 'Switched view should keep elements');
    return equal((wrapper.find('div.switch')).length, 0, 'Switched view should remove "switch" elements');
  });

}).call(this);
