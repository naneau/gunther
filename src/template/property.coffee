### Public ###
#
# Properties and Attributes
#
# Set an attribute
#
# Uses jQuery's `attr()` method
#
# name - {String} name of the attribute to add
# value - {String} value for the attribute
Gunther.Template::attribute = (name, value) ->

  # Current element
  el = @current

  # Set up binding for bound properties
  if value instanceof BoundProperty

    # Set the base value
    el.attr name, value.getValue()

    # On change re-set the attribute
    value.bind 'change', (newValue) -> el.attr name, value.getValue()

  # Else try to set directly
  else
    el.attr name, value

  null

# Add a DOM attribute which is "bound" to a model's attribute
#
# name - {String} name of the attribute to add
# model - {Backbone.Model} to bind on
# property - {String} or {Array} of properties to bind on
# generator - (optional) method that generates the value after a change
Gunther.Template::boundAttribute = (args...) -> @attribute (do args.shift), new BoundProperty args...

# Set a property
#
# note: this differs from attributes, as per jQuery's API. Use this for
# properties like `checked` on a checkbox
#
# name - {String} name of the property to add
# value - {String} value for the attribute
Gunther.Template::property = (name, value) ->

  # Current element
  el = @current

  # Set up binding for bound properties
  if value instanceof BoundProperty

    # Set the base value
    el.prop name, value.getValue()

    # On change re-set the property
    value.bind 'change', (newValue) -> el.prop name, value.getValue()

  # Else try to set directly
  else
    el.prop name, value

  null

# Add a property which is "bound"
#
# Pass it the property's name, the model, the property, and optionally a
# value generating function
#
# name - {String} name of the property to add
# model - {Backbone.Model} to bind on
# property - {String} or {Array} of properties to bind on
# generator - (optional) method that generates the value after a change
Gunther.Template::boundProperty = (args...) -> @property (do args.shift), new BoundProperty args...

# Set a style property
#
# This method accepts both an object of the form `cssKey: value` or a single
# name/value pair
#
# name - name of the CSS property
# value - value of the CSS property
Gunther.Template::css = (name, value) ->

  # When hash is passed, run each item through @css
  return (@css realName, value for realName, value of name) if name instanceof Object

  # Current element
  el = @current

  # Set up binding for bound properties
  if value instanceof BoundProperty

    # Set the base value
    el.css name, value.getValue()

    # On change re-set the attribute
    value.bind 'change', (newValue) -> el.css name, newValue

    return el

  # Else try to set directly
  else
    el.css name, value

  null

# Bind a CSS property to a model's property or properties
#
# name - {String} name of the CSS property
# model - {Backbone.Model} to bind on
# property - {String} or {Array} of properties to bind on
# generator - (optional) method that generates the value after a change
Gunther.Template::boundCss = (args...) -> @css (do args.shift), new BoundProperty args...

# Toggle an element's class based on a property (or set of properties)
#
# className - {String} name of the class to toggle
# model - {Backbone.Model} to bind on
# property - {String} or {Array} of properties to bind on
# toggle - method that decides whether the class should be included or not,
#   should return a {Boolean}
Gunther.Template::toggleClass = (className, model, property, toggle) ->

  # Make sure we get an array of props
  properties = [].concat property

  # When no toggle is passed simply use a property value
  unless toggle instanceof Function then toggle = (value) -> value

  # Track the element
  element = @current

  # Perform the class toggle
  performToggle = (model, value) ->
    ($ element).toggleClass className, toggle value

  # For every property in the list
  for property in properties

    model.on "change:#{property}", performToggle

    performToggle model, model.get property

  null
