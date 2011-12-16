# Example view class
class ExampleView extends Backbone.View

    # Template sets up the container
    @template = new Gunther.Template (collection) ->

        # Set up some controls for adding/removing items
        @div ->
            @a click: ((e) -> collection.add new ExampleModel), -> 'Add an item '
            @a click: ((e) -> collection.removeRandom()), -> 'Remove a random item'

        # Set up sub views for all items in the collection
        @div -> @itemSubView
            # Model to use
            model: collection

            # Generator for the subview
            generator: (item) -> new Gunther.Template ->
                # Set up a container class (which will be the "el" in the view)
                @li class: "container-#{item.get 'index'}", (element) -> new ItemView
                    model: item,
                    element: element # element is the li

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
