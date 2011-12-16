# Subview for items
#
# Will maintain its element with a list of items that come from a collection. Adding new elements and removing old ones
class ItemSubView extends Backbone.View

    # ID Generator
    @generator: new Gunther.IDGenerator

    # Constructor
    initialize: (options) ->

        # Identifiers to store view/dom element under
        @key = "_subview-#{ItemSubView.generator.generate()}"
        @elementKey = "_subview-element-#{options.key}"

        # Prepend instead of append elements?
        @prepend = if options.prepend? then options.prepend else false

        # View/Template generator
        @generator = options.generator

        # Init the items
        @model.each (item) => @initItem item

        # When an item is added, init and render it
        @model.bind 'add', (item) =>
            @initItem item
            @renderItem item

        # When an item is removed, remove the element, or the view
        @model.bind 'remove', (item) =>
            # Guard, we may be removed before our own 'add' event fired
            return if not item[@key]?

            if item[@key] instanceof Backbone.View
                item[@key].remove()
            else
                item[@elementKey].remove()

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

        # Append the results
        if @prepend
            @el.prepend item[@elementKey]
        else
            @el.append item[@elementKey]

    # Render the subview
    render: () ->
        # Render the items already in the collection
        @model.each (item) => @renderItem item

