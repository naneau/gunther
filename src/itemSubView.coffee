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
        parentElement.append item for item in items

    # Constructor
    initialize: (options) ->

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

        # Hash of items that have been rendered
        @renderedItems = {}

        # Init the items
        @model.each (item) => @initItem item

        # When an item is added, init and render it
        @model.bind 'add', (item) => @addItem item

        # When an item is removed, remove the element, or the view
        @model.bind 'remove', (item) => @removeItem item

        # Naive Sort
        @model.bind 'sort', () => ItemSubView.naiveSort @model, @$el, @elementKey

        # If the entire collection is reset, remove all items
        @model.bind 'reset', (newItems) =>

            # Remove all items we had previously rendered
            @removeItem item for key, item of @renderedItems

            # Add the new items
            newItems.each (item) => @addItem item

    # Overloaded setElement() because of lack of @$el in init
    setElement: (@$el) ->

    # Add an item
    addItem: (item) ->
        @initItem item
        @renderItem item

    # Remove an item
    removeItem: (item) ->
        # Guard, we may be removed before our own 'add' event fired
        return if not item[@key]?

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

        # Remove the item from our hash of items we rendered
        delete @renderedItems[item.cid]

    # Init the view in the item
    initItem: (item) ->
        item[@key] = @generator item

    # Render a single item
    renderItem: (item) ->
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

        # Append the results
        if @prepend
            @$el.prepend item[@elementKey]
        else
            @$el.append item[@elementKey]

        # Post-insert event
        @events.postInsert item[@elementKey], @$el

        # Set up a hash with all rendered items
        @renderedItems[item.cid] = item

    # Render the subview
    render: () ->
        # Render the items already in the collection
        @model.each (item) => @renderItem item

