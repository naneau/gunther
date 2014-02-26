# Public: The Main Gunther Template Class
#
# Main template class
class Gunther.Template

  # additional DOM parsers, can be used to set up plugins, etc.
  @domParsers = []

  # Value for an element whereby both a function and a direct value can be passed
  # scope is optional
  @elementValue: (generator, scope = {}) ->
    return generator.apply scope if typeof generator is 'function'

    generator

  # Private: Generate children for a DOM element
  #
  # el: current element
  # childFn: child generating method
  # scope: current scope
  @generateChildren: (el, childFn, scope) ->

    # Do the actual recursion, setting up the scope proper, and passing the parent element
    childResult = Gunther.Template.elementValue childFn, scope

    # Make sure we get a result in the first place
    return if childResult is undefined

    # If the child generator returns a string, we have to append it as a text element to the current element
    el.append document.createTextNode childResult if typeof childResult isnt 'object'

    # If we get a bound property or model, we set up the initial value, as well as a change watcher
    if childResult instanceof BoundProperty or childResult instanceof BoundModel

      # Initial generated value
      childResult.getValueInEl el

      # Track changes in the bound property
      childResult.bind 'change', (newVal) ->

        # Empty the node for updates
        el.empty()

        # Set the new value
        childResult.getValueInEl el

    else if childResult instanceof Gunther.SwitchedView
      do childResult.render

    # The child is a new View instance, we set up the proper element and render it
    else if childResult instanceof Backbone.View

      # Set the view's element to the current one
      childResult.setElement el

      # Render the view
      childResult.render()

  # Constructor
  constructor: (@fn) -> null

  # Public: Render the template
  #
  # Returns an Array of DOM elements
  render: (args...) ->

    # Set up a root element, its children will be transferred
    @root = $ '<div />'

    # Current element, starts out as the root element, but will change in the tree
    @current = @root

    # Start the template function
    @fn.apply this, args

    # Add all children of root to the element we're supposed to render into
    children = @root.contents()

    # Parse dom with the DOM parsers
    for domParser in Gunther.Template.domParsers
      for child in children
        domParser child

    children

  # Public: Render into an element
  #
  # This will *append* the elements from the template into the passed DOM element
  #
  # It returns the rendered elements
  renderInto: (el, args...) ->

    children = @render args...

    # Append a child for every element @render returns
    ($ el).append child for child in children

    children

  # Public: Render a sub-template
  subTemplate: (template, args...) -> template.renderInto @current, args...

  # Bind an attribute or property to a property of a model
  bind: (args...) -> new BoundProperty args...

  # Register a change handler for a model
  onModel: (model, event, handler) ->
    current = @current

    model.on event, (args...) -> handler.apply this, [current].concat args

  # Aliases for shorter notation

  # Public: Alias for `@element()`
  e: (tagName, args...) -> @element tagName, args...

  # Public: Alias for `@text()`
  t: (args...) -> @text args...

  # Public: Alias for `@attribute()`
  attr: (args...) -> @attribute.apply this, args

  # Public: Alias for `@property`
  prop: (args...) -> @property.apply this, args

  # Public: Alias for `@attribute 'class', className`
  class: (className) -> @attribute 'class', className
