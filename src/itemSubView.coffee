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
    Gunther.Helper.animationFrame => do @_checkQueue

  # Check the queues for added/removed items and render/remove them
  _checkQueue: ->

    return if @_checkingQueue

    @_checkingQueue = true

    #console.log "adding #{@_addItems.length}, removing #{@_removeItems.length}"

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
