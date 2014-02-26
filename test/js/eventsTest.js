(function() {
  module('Events');

  asyncTest('Handling', function() {
    var wrapper;
    expect(1);
    wrapper = renderGunther(new Gunther.Template(function() {
      return this.element('div', function() {
        return this.on('click', function(e) {
          ok(true);
          return start();
        });
      });
    }));
    return (wrapper.find('div')).trigger('click');
  });

}).call(this);
