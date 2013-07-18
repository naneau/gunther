# A simple model
#
# has a property "autoUpdated" that gets updated every second, to show off
# bindings
class ExampleModel extends Backbone.Model

    # Constructor
    initialize: () ->

        # Set up some stuff
        @set
            text: 'This is some text...'
            autoUpdated: 0

        # Update "autoUpdated" every second
        setInterval (=> @update()), 1000

    # Update function, called by interval
    update: () ->
        @set
            autoUpdated: (@get 'autoUpdated') + 1

# Example collection, sets up 10 ExampleModel's
class ExampleCollection extends Backbone.Collection

    # Model
    model: ExampleModel

    # Constructor
    initialize: () ->


        # Set an index in all items
        @index = 0
        @bind 'add', (item) =>
            item.set
                index: @index++
                value: Math.round Math.random() * 100

        # Set up 10 sample items
        for x in [0..10]
            @add new ExampleModel

    # Default sorting var
    sortVar: 'index'

    comparator: (item) -> item.get @sortVar

    # Remove a random item
    removeRandom: () ->
        # Guard
        return if @size() is 0

        # Remove the item
        @remove @at Math.floor Math.random() * @size()

# Export the classes
window.ExampleModel = ExampleModel
window.ExampleCollection = ExampleCollection
