# Public: Add a child element
#
# tagName - String with the name of the element (i.e. "a", "div", etc)
Gunther.Template::element = (tagName, args...) ->

  # Element we're working on starts out with the current one set up in
  # the "this" scope. This will change in the child rendering, so we need
  # to retain a reference
  current = @current

  # Element to render in
  el = Gunther.Helper.createHtmlElement tagName

  # Change current element to the newly created one for our children
  @current = el

  # The last argument
  lastArgument = args[args.length - 1]

  # We have to recurse, if the last argument passed is a function
  if typeof lastArgument is 'function'
    Gunther.Template.generateChildren el, args.pop(), this

  # Bound property or model passed?
  else if lastArgument instanceof BoundProperty or lastArgument instanceof BoundModel
    Gunther.Template.generateChildren el, args.pop(), this

  # If we get passed a string as last value, set it as the node value
  else if typeof lastArgument is 'string'
    el.append document.createTextNode args.pop()

  # Append it to the current element
  current.append el

  # Set the now current again element in the this scope
  @current = current

  null

# Public: Set up an element which is bound to a model's property
#
# element - string to pass to {Gunther.Template::element}
# model - model to bind on
# properties - single or list of properties to listen to (given as {String})
Gunther.Template::boundElement = (args...) -> @element (do args.shift), new BoundModel args...

# Public: Append an element
#
# element - element to append, can be a {Backbone.View} or anything that can be
#   appended directly to the DOM
Gunther.Template::append = (element) ->
  if element instanceof Backbone.View
    # The element is a Backbone view

    # Render it
    element.render()

    # Append its element
    @current.append element.el

  else
    # Assume it can be appended directly
    @current.append element
