# Render a template-like thing and return a single element described by the
# find param. Intended to render a single element (with or without children)
# using Gunther, then retreive it for testing.
#
# Usage like:
#   singleElement 'div', 'div.foo'
#
# which is equivalent to
#   singleElement 'div', -> @element 'div.foo'
#
window.singleElement = (find, args...) ->

  # Get the template
  desc = do args.pop
  if typeof desc is 'string'
    template = new Gunther.Template -> @element desc
  else if typeof desc is 'function'
    template = new Gunther.Template desc
  else if desc instanceof Gunther.Template
    template = desc

  wrapper = renderGunther template, args...

  wrapper.find find

# Render a template into a wrapper appended to the body on the fly
window.renderGunther = (template, args...) ->
  wrapper = ($ '<div class="gunther-output"></div>')

  ($ 'body').append wrapper

  template.renderInto.apply template, [wrapper].concat args

  wrapper

window.renderGuntherView = (view, args...) ->
  wrapper = ($ '<div class="gunther-output"></div>')

  ($ 'body').append wrapper

  # Set the element
  view.setElement wrapper

  # Render
  view.render.apply view, [wrapper].concat args

  wrapper
