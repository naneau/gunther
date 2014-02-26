# Public: Add an event handler
#
# Set up an event handler for DOM events, uses jQuery's `bind()`
#
# event - event name
# handler - handler method
Gunther.Template::on = (event, handler) -> @current.bind event, handler

# Public: A "halted" on, that has no propagation (and no default)
#
# Before the `handler` is called, the `stopPropagation()` and
# `preventDefault()` are called on the event
#
# See {Gunther.Template::on}
#
# event - event name
# handle - handling method
Gunther.Template::haltedOn = (event, handler) -> @current.bind event, (event) ->
  do event.stopPropagation
  do event.preventDefault

  handler event

# Public: Show/hide an element based on a boolean property
#
# model - The model to bind on
# properties - Either a single property, or a list or properties (given as string)
# resolver - a method that will return a {Boolean} method that determines
#   whether the element should be visible or not
Gunther.Template::show = (model, properties, resolver) ->

  # Hold on to current element
  element = @current

  # Initialize resolver when not passed
  (resolver = (value) -> value) unless resolver?

  # The actual show method
  show = (element, shown) -> if shown then do ($ element).show else do ($ element).hide

  for property in [].concat properties
    do (property) =>

      # Track changes
      model.on "change:#{property}", (model) ->
        show element, resolver model.get property

      # Initial show/hide
      show element, resolver model.get property

# Public: Hide/show an element based on a boolean property
#
# This is simply show() inverted
#
# See {Gunther.Template::hide}
#
# model - The model to bind on
# properties - Either a single property, or a list or properties (given as string)
# resolver - a method that will return a {Boolean} method that determines
#   whether the element should be hidden or not
Gunther.Template::hide = (model, properties, resolver) ->

  # Initialize resolver when not passed
  (resolver = (value) -> value) unless resolver?

  @show model, properties, (value) -> not resolver value

