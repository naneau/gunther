# Example view
class ExampleView extends Backbone.View

    # Simple template, renders an unordered list for every item
    @template: new Gunther.Template (model) ->

        @section () ->

            # Simple text and a property from the model get set up as headers
            @h1 -> 'Basic Example'
            @text -> model.get 'text'

            # A bound property will refresh its contents when the property in the model changes
            @div -> @bind model, 'autoUpdated'

            # You can also set up a value generating function for a bound property
            @text -> @bind model, 'autoUpdated', () ->
                "The valued of 'autoUpdated' was updated #{model.get 'autoUpdated'} times"

            # Not all tags need parameters
            @br()

            # While all HTML elements are set up as alias functions, you can
            # also create an element for non standard tags, in this case <foo />
            @addElement 'foo', -> 'This is a <foo /> element'

    # Render the template into our DOM element
    render: () -> ExampleView.template.renderInto @el, @model

# Export the view class
window.ExampleView = ExampleView
