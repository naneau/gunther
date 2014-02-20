# Set up the global "namespace" for Gunther to live in
Gunther = {
  # Partial renderers
  partials: {}

  # Add a partial
  addPartial: (key, partial) ->

    # Set it up as a partial
    Gunther.partials[key] = partial

    # Register as a method on root
    throw new Error "Partial \"#{key}\" already exists" if Gunther.Template::[key]?

    # Register on template
    Gunther.Template::[key] = (args...) -> @partial.apply this, [key].concat args
}

# Export through CommonJS if we have a require function
# This is a tad hacky for now
#
if require?
  module.exports = Gunther

  # Require dependencies
  _ = require 'underscore'
  Backbone = require 'backbone'

else
  # Export Gunther to the global scope
  window.Gunther = Gunther

  # Require dependencies
  { _, Backbone } = window

# Make sure we have underscore.js
throw new Error 'Underscore.js must be loaded for Gunther to work' if (typeof _) is not 'function'

class Gunther.Helper
  # Create a DOM element
  #
  # Accepts simple class/id descriptors too, in the form of div.foo/div#foo
  @createHtmlElement: (description) ->

    # Description the string into relevant tokens
    tokens = _.filter (description.split /(?=\.)|(\[.+\=.+\])|(\:[a-z0-9]+)|(?=#)/), (t) -> t?

    # Make sure we get at least one token
    throw new Error "Invalid element description #{description}" unless tokens.length >= 1

    # Tag name to create
    tagName = tokens[0]

    # Sanity check for tag name
    throw new Error "Invalid tag name #{tagName}" unless /^[a-zA-Z0-9]+$/.test tagName

    # Create the element
    element = $(document.createElement tagName)

    # Return if element name matches description (avoid further regexing)
    return element if tagName is description

    # Parse remainder of tokens
    for token in tokens
      # ID
      if token[0] is '#'
        element.attr 'id', token.substr 1

      # Class
      else if token[0] is '.'
        previousClass = if (element.attr 'class')? then (element.attr 'class') + ' ' else ''
        element.attr 'class',  previousClass + token.substr 1

      # Property, like :checked
      else if token[0] is ':'
        element.prop (token.substr 1), true

      # Attribute, like [foo=bar]
      else if token[0] is '[' and token[token.length = 1] = ']'

        # Split into parts
        attributeDefinition = ((token.substr 1).substr 0, token.length - 2).split '='

        # Make sure we get two parts as required
        continue if attributeDefinition.length isnt 2

        element.attr attributeDefinition[0], attributeDefinition[1]

    # Return the element
    element

  # Set up an animation frame callback
  @animationFrame: (callback) ->
    return @_requestAnimationFrame.call window, callback

  # Browser's requestAnimationFrame
  @_requestAnimationFrame =
    window.requestAnimationFrame       ||
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame    ||
    window.oRequestAnimationFrame      ||
    window.msRequestAnimationFrame     ||
    (callback, element) ->
      window.setTimeout(
        -> callback(+new Date()),
        17 # ~1000/60
      )

# ID Generator
class Gunther.IDGenerator

  # Constructor
  constructor: () ->
    @value = 0

  # Generate
  generate: () -> @value++



# Bound property, a simple wrapper around the events the Backbone models fire
class BoundProperty

  # Constructor
  constructor: (@model, @propertyNames, @valueGenerator) ->

    # Default the value generator to a "get" of the property if we can
    if not @valueGenerator? and typeof @propertyNames is 'string'
      @valueGenerator = () => @model.get @propertyNames[0]

    # Make sure we have an array of property names (a string can be passed)
    @propertyNames = [].concat @propertyNames

    # Set up a listener for all the property names we need to watch
    for propertyName in @propertyNames
      @model.bind "change:#{propertyName}", () =>
        @trigger 'change', @getValue()

  # Get the value
  getValue: () ->
    generatedValue = @valueGenerator()
    if generatedValue instanceof Gunther.Template
      generatedValue.render()
    else
      generatedValue

  # Get value into a DOM element
  getValueInEl: (el) ->

    # Generate the value through the generator
    generatedValue = @valueGenerator()

    # If it is a child template, render it into el
    if generatedValue instanceof Gunther.Template
      generatedValue.renderInto el, @model

    # Render subview
    else if generatedValue instanceof Backbone.View
      generatedValue.setElement el
      generatedValue.render()

    # Simply set as HTML
    else
      if el.length > 0
        for element in el
          element.textContent = generatedValue
      else
        el.textContent = generatedValue

# BoundProperty is an EventEmitter... (why can't I just extend from Backbone.Events?)
_.extend BoundProperty.prototype, Backbone.Events

# Bind a full element to a model's property
class BoundModel

  # Constructor
  constructor: (@model, @propertyName, templateAndArgs...) ->

    @template = do templateAndArgs.pop
    @args = templateAndArgs

    # If we are passed a function, that isn't a template, make it a template
    if typeof @template is 'function' and @template not instanceof Gunther.Template
      @template = new Gunther.Template @template

    # Store the current value
    @currentValue = @model.get @propertyName

    # Listen to changes
    @model.bind "change:#{@propertyName}", (parent) =>

      # The new value
      newValue = parent.get @propertyName

      # Make sure there's actual change
      return if newValue is @currentValue

      # Store the current value
      @currentValue = newValue

      # Trigger change
      @trigger 'change', newValue

  # Get value into a DOM element
  getValueInEl: (el) ->
    @template.renderInto.apply @template, [].concat el, (@model.get @propertyName), @args

# BoundModel is an EventEmitter... (why can't I just extend from Backbone.Events?)
_.extend BoundModel.prototype, Backbone.Events


# Main template class
class Gunther.Template

  # additional DOM parsers, can be used to set up plugins, etc.
  @domParsers = []

  # Remove a partial
  @removePartial = (key) -> delete Gunther.Template.partials.key

  # Value for an element whereby both a function and a direct value can be passed
  # scope is optional
  @elementValue: (generator, scope = {}) ->
    return generator.apply scope if typeof generator is 'function'

    generator

  # Generate children for a DOM element
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

  # Render
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

  # Render into an element
  #
  # This will *append* the elements from the template into the passed DOM element
  #
  # It returns the rendered elements
  renderInto: (el, args...) ->

    children = @render args...

    # Append a child for every element @render returns
    ($ el).append child for child in children

    children

  # Add text to the current element
  #
  # This will create a text node and append it to the current element, the
  # contents of which can be either a string, or a bound property (see
  # @bind())
  text: (text) ->

    # Create text node
    el = document.createTextNode ''

    # Set the contents of the child node
    if typeof text is 'string'
      el.nodeValue = text
    else
      # Get value for child result
      childResult = Gunther.Template.elementValue text, this

      # If we get a bound property, we set up the initial value, as well as a change watcher
      if childResult instanceof BoundProperty
        el.nodeValue = childResult.getValue()
        childResult.bind 'change', (newVal) ->
          el.nodeValue = newVal

      # If not, we just set the result as the value
      else
        el.nodeValue = childResult

    # Append the child node
    @current.append el

  # Bound text
  boundText: (args...) -> @text new BoundProperty args...

  # Spaced text
  spacedText: (text) -> @text " #{text} "

  # Create a child to @current, recurse and add children to it, etc.
  element: (tagName, args...) ->

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

  # Set up an element which is bound to a model's property
  boundElement: (args...) -> @element (do args.shift), new BoundModel args...

  # Set an attribute
  attribute: (name, value, args...) ->

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

  # Add up an attribute which is "bound"
  # Pass it the attributes name, the model, the property, and optionally a
  # value generating function
  boundAttribute: (args...) -> @attribute (do args.shift), new BoundProperty args...

  # Set a property (note this differs from attributes, as per jQuery's API)
  property: (name, value, args...) ->

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

  # Add up a property which is "bound"
  # Pass it the property's name, the model, the property, and optionally a
  # value generating function
  boundProperty: (args...) -> @property (do args.shift), new BoundProperty args...

  # Set a style property
  css: (name, value) ->

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

  # Bound CSS property
  boundCss: (args...) -> @css (do args.shift), new BoundProperty args...

  # Show/hide an element based on a boolean property
  show: (model, properties, resolver) ->

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

  # Hide/show an element based on a boolean property
  # This is simply show() inverted
  hide: (model, properties, resolver) ->

    # Initialize resolver when not passed
    (resolver = (value) -> value) unless resolver?

    @show model, properties, (value) -> not resolver value

  # Toggle a class
  toggleClass: (className, model, properties, toggle) ->

    # Make sure we get an array of props
    properties = [].concat properties

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

  # Set up an event handler for DOM events
  on: (event, handler) -> @current.bind event, handler

  # A "halted" on, that has no propagation (and no default)
  haltedOn: (event, handler) -> @current.bind event, (event) ->
    do event.stopPropagation
    do event.preventDefault

    handler event

  # Append an element
  append: (element) ->
    if element instanceof Backbone.View
      # The element is a Backbone view

      # Render it
      element.render()

      # Append its element
      @current.append element.el

    else
      # Assume it can be appended directly
      @current.append element

  # Render a sub-template
  subTemplate: (template, args...) -> template.renderInto @current, args...

  # Render a registered partial
  partial: (key, args...) ->

    # Sanity check
    throw new Error "Partial \"#{key}\" does not exist" if not Gunther.partials[key]?

    template = new Gunther.Template Gunther.partials[key]

    @subTemplate.apply this, [template].concat args

  # Bind an attribute or property to a property of a model
  bind: (args...) -> new BoundProperty args...

  # Register a change handler for a model
  onModel: (model, event, handler) ->
    current = @current

    model.on event, (args...) -> handler.apply this, [current].concat args

  # Aliases for shorter notation

  # Alias for element
  e: (tagName, args...) -> @element tagName, args...

  # Alias for add text
  t: (args...) -> @text args...

  # Attribute
  attr: (args...) -> @attribute.apply this, args
  a: (args...) -> @attribute.apply this, args

  # Property
  prop: (args...) -> @property.apply this, args

  # Shorthand for class
  class: (className) -> @attribute 'class', className

  # Partial
  p: (args...) -> @partial.apply this, args

# Switched views
#
# Set up a switched view
#@switchView 'div.switched', state, 'toggle', ->
  #@keep templateKeep, state, (toggle) -> toggle
  #@switch templateSwitch, state, (toggle) -> not toggle
  #
Gunther.Template::switchView = (element, model, properties, generator) ->
  @element element, ->
    return new SwitchedView @current, model, properties, generator

class SwitchedView
  switches: []

  # Constructor
  #
  # Expects the parent DOM element, the model/attributes to watch for and a
  # generator method that sets up the switching
  constructor: (@parent, @model, @attributeName, generator) ->
    # Set up change handlers
    @model.on "change:#{@attributeName}", => do @render

    # Actual specification for the switch
    generator.apply this, [@model]

  # Decided active switch and render
  render: ->

    # Make old active switch unactive
    @active.makeUnActiveIn @parent if @active?

    # Find the new active switch
    @active = _.find @switches, (viewSwitch) => viewSwitch.isActive @model.get @attributeName

    # Make it active
    @active.makeActiveIn @parent

  keep: (template, args...) ->
    @switches.push new ViewSwitch ViewSwitch.KEEP, template, args...

  switch: (template, args...) ->
    @switches.push new ViewSwitch ViewSwitch.SWITCH, template, args...

# Single switch
class ViewSwitch

  @KEEP: 'keep'
  @SWITCH: 'switch'

  isActive: false

  constructor: (@type, @template, args...) ->

    # Switch method
    @determinator = do args.pop

    # Left over arguments for tempalte
    @arguments = args

  # Determinate whether this switch is active or not
  isActive: (value) -> @determinator value

  # Make this ViewSwitch active in a DOM element
  makeActiveIn: (element) ->

    # If this view has been active before, simply show the hidden elements again
    if @switchedElements?
      do @switchedElements.show

    # If not, render the template
    else
      @switchedElements = @template.renderInto.apply @template, [element].concat @arguments

  # Make this ViewSwitch unactive
  makeUnActiveIn: (element) ->

    # If this is a kept switch, hide the elements
    if @type is ViewSwitch.KEEP
      do @switchedElements.hide

    # If it's not, destroy them
    else
      do @switchedElements.remove

      @switchedElements = null

# Export to Gunther scope
Gunther.SwitchedView = SwitchedView

# Set up a subview for every item in the collection
Gunther.Template::itemSubView = (options, generator = null) -> new ItemSubView options, generator

# Create a list
Gunther.Template::list = (element, options, generator = null) -> @element element, -> new ItemSubView options, generator

# Create a sync list, that does not wait for animation frames
Gunther.Template::syncList = (element, options, generator = null) ->

  if options instanceof Backbone.Collection
    model = options

    options =
      model: model
      generator: generator

  options.sync = true

  @element element, -> new ItemSubView options

# Subview for items
#
# Will maintain its element with a list of items that come from a collection
# adding new elements and removing old ones. The item sub view is set up with
# both a collection and a "generator". This generator function will be called
# for each and every item in the collection, and is supposed to return either a
# Gunther.Template, or a Backbone.View instance.
class ItemSubView extends Backbone.View

  # Remove element
  @remove: (element) -> ($ element).remove()

  # Default event handlers
  @defaultEvents:
    preRemove: () -> null
    postRemove: () -> null

    preInsert: () -> null
    postInsert: () -> null

  # ID Generator
  @generator: new Gunther.IDGenerator

  # Naive sort, will detach all elements, then reattach them in order
  # This may *not* be efficient for larger collections
  @naiveSort: (collection, parentElement, elementKey) ->
    # Detach
    items = (item[elementKey].detach() for item in collection.toArray())

    # Append again from the top
    parentElement.appendChild item for item in items

  # Constructor
  initialize: (options, generator) ->

    # Alias when given two params (model and the generator)
    if options instanceof Backbone.Collection
      @model = options

      options =
        model: options
        generator: generator

    # Identifiers to store view/dom element under
    @key = "_subview-#{ItemSubView.generator.generate()}"
    @elementKey = "element-#{@key}"

    # Prepend instead of append elements?
    @prepend = if options.prepend? then options.prepend else false

    # View/Template generator
    @generator = options.generator

    # Events hash
    @events = _.extend ItemSubView.defaultEvents, (if options.events? then options.events else {})

    # DOM element remover
    @remove = if options.remove? then options.remove else ItemSubView.remove

    # Odd/Even classes
    @evenClass = if options.evenClass? then options.evenClass
    @oddClass = if options.oddClass? then options.oddClass

    # Hash of items that have been rendered
    @renderedItems = {}

    # Sync operation?
    @sync = if options.sync? then options.sync else false

    # Alias for "collection"
    @model = if options.collection? then options.collection else @model

    do @_initEvents

  # Overloaded setElement() because of lack of @$el in init
  setElement: (@$el) ->

  # Render the subview
  render: () ->

    # Initialize all items that exist in the collection already
    @model.each (item) => @_initItem item

    # Render the items already in the collection
    @model.each (item) => @_renderItem item

  # Initialize the event listeners
  _initEvents: () ->

    # Initialize queues
    @_addItems = []
    @_removeItems = []
    @_checkingQueue = false

    # When an item is added, init it and add render to the queue
    @model.bind 'add', (item) => @_addItemToAddQueue item

    # When an item is removed, add it to the remove queue
    @model.bind 'remove', (item) => @_addItemToRemoveQueue item

    # Naive Sort
    @model.bind 'sort', () => ItemSubView.naiveSort @model, @$el, @elementKey

    # If the entire collection is reset, remove all items
    @model.bind 'reset', (newItems) =>

      # Remove all items we had previously rendered
      @removeItem item for key, item of @renderedItems

      # Add the new items
      newItems.each (item) => @addItem item

  # Render a single item
  _renderItem: (item) ->

    # If the generator returned a template, we simply render it and fetch the returned element(s)
    if item[@key] instanceof Gunther.Template
      item[@elementKey] = item[@key].render item

    # If the item is a view, we render it and fetch it's element
    else if item[@key] instanceof Backbone.View
      item[@key].render()
      item[@elementKey] = item[@key].el

    # There is no else.
    else
      throw new Error 'Generator must return either a Gunther.Template or a Backbone.View instance'

    # Pre-insert event
    @events.preInsert item[@elementKey], @$el

    if @evenClass? and (@model.indexOf item) % 2 is 0
      ($ item[@elementKey]).addClass @evenClass
    else if @oddClass?
      ($ item[@elementKey]).addClass @oddClass

    # Append the results
    if @prepend
      @$el.prependChild item[@elementKey]
    else
      ($ @$el).append item[@elementKey]

    # Post-insert event
    @events.postInsert item[@elementKey], @$el

    # Set up a hash with all rendered items
    @renderedItems[item.cid] = item

  # Actual remove of item
  _removeItem: (item) ->
    # Item is either a Backbone view
    if item[@key] instanceof Backbone.View

      # Pre-remove event
      @events.preRemove item[@key]

      # Call Backbone View's remove function
      item[@key].remove()

      # Post remove event
      do @events.postRemove

    # Or it's a DOM element
    else
      # Pre-remove event
      @events.preRemove item[@elementKey]

      # Remove the item
      @remove item[@elementKey]

      # Post remove event
      do @events.postRemove

      # Delete the reference to the DOM element
      delete item[@elementKey]

    # Remove the item from our hash of items we rendered
    delete @renderedItems[item.cid]

  # Init the view in the item
  _initItem: (item) ->
    if typeof @generator is 'function'
      item[@key] = @generator item
    else
      item[@key] = @generator

  # Work queue, keeps track of a stack of items to be added/removed, and does
  # this all in one sweep using animation frames. Should make for smoother
  # operation when larger sets of items are added/removed.

  # Animation frame item queues

  # Add an item to the add queue
  _addItemToAddQueue: (item) ->

    # Initialize the item
    @_initItem item

    @_addItems.push item
    do @_addQueueCheck

  # Add an item to the remove queue
  _addItemToRemoveQueue: (item) ->
    # Guard, we may be removed before our own 'add' event fired
    return if not item[@key]?

    @_removeItems.push item
    do @_addQueueCheck

  # Set up a queue check
  _addQueueCheck: ->
    return do @_checkQueue if @sync

    Gunther.Helper.animationFrame => do @_checkQueue

  # Check the queues for added/removed items and render/remove them
  _checkQueue: ->

    return if @_checkingQueue

    @_checkingQueue = true

    # Render all new items for this frame
    @_renderItem.apply this, [item] for item in @_addItems

    # Remove all items for this frame
    for item, index in @_removeItems
      @_removeItem item

    # Empty queues
    @_addItems = []
    @_removeItems = []

    # Switch semaphore
    @_checkingQueue = false
