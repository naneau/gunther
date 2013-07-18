# Example view class
class ExampleView extends Backbone.View

    # Template sets up the container
    @template = new Gunther.Template (collection) ->

        # Set up some controls for adding/removing items
        @e 'div', ->

            @e 'a', ->
                @on 'click', (e) ->
                    collection.add new ExampleModel

                @text 'Add an item '

            @e 'a', ->
                @on 'click', (e) ->
                    collection.removeRandom()

                @text 'Remove a random item'

        # Set up sub views for all items in the collection
        itemCount = 0
        @e 'div', -> @itemSubView

            # Model to use
            model: collection

            # Generator for the subview
            generator: (item) -> new Gunther.Template ->
                @e 'div', "This is item #{itemCount++}"

    # Render
    render: () ->
        ExampleView.template.renderInto @el, @model

# Export the view to the global scope
window.ExampleView = ExampleView

# The view for a single item
class ItemView extends Backbone.View

    # Template for the item
    @template: new Gunther.Template (item) ->
        @section id: "item-#{item.get 'index'}", ->
            @h1 -> item.get 'text'
            @h2 -> "Item number #{item.get 'index'}"

            # Updated value, just the contents of this element will be re-rendered
            @p -> @bind item, 'autoUpdated', () -> "This element was updated #{item.get 'autoUpdated'} times"

    # Render
    render: () ->
        ItemView.template.renderInto @el, @model
