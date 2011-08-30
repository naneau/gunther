# Subview for items
class ItemSubView extends Backbone.View

    # Constructor
    initialize: (options) ->

        # Identifiers to store view/dom element under
        @key = "_subview-#{options.key}"
        @elementKey = "_subview-element-#{options.key}"

        # View/Template generator
        @generator = options.template

        # Init the items
        @model.each (item) => @initItem item

    # Init the view in the item
    initItem: (item) ->
        item[@key] = @generator item
        console.log item[@key]

    # Render a single item
    renderItem: (item) ->
        # If the generator returned a template, we simply render it and fetch the returned element(s)
        if item[@key] instanceof Gunther.Template
            item[@elementKey] = item[@key].render item

        # If the item is a view, we render it and fetch it's element
        else if item[@key] instanceof Backbone.View
            item[key].render()
            item[@elementKey] = item[@key].el

        # There is no else.
        else
            throw new Error 'Generator must return either a Gunther.Template or a Backbone.View instance'

        # Append the results
        @el.append item[@elementKey]

    # Render the subview
    render: () ->
        # Render the items already in the collection
        @model.each (item) => @renderItem item

