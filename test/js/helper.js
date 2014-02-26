(function() {
  var __slice = [].slice;

  window.singleElement = function() {
    var args, desc, find, template, wrapper;
    find = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    desc = args.pop();
    if (typeof desc === 'string') {
      template = new Gunther.Template(function() {
        return this.element(desc);
      });
    } else if (typeof desc === 'function') {
      template = new Gunther.Template(desc);
    } else if (desc instanceof Gunther.Template) {
      template = desc;
    }
    wrapper = renderGunther.apply(null, [template].concat(__slice.call(args)));
    return wrapper.find(find);
  };

  window.renderGunther = function() {
    var args, template, wrapper;
    template = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    wrapper = $('<div class="gunther-output"></div>');
    ($('body')).append(wrapper);
    template.renderInto.apply(template, [wrapper].concat(args));
    return wrapper;
  };

  window.renderGuntherView = function() {
    var args, view, wrapper;
    view = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    wrapper = $('<div class="gunther-output"></div>');
    ($('body')).append(wrapper);
    view.setElement(wrapper);
    view.render.apply(view, [wrapper].concat(args));
    return wrapper;
  };

}).call(this);
