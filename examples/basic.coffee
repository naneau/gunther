# Example view
class ExampleView extends Backbone.View

    # Simple template, renders an unordered list for every item
    @template: new Gunther.Template (model) ->

        # Nested section
        @e 'section', () ->

            @property 'class', 'test'

            # A header
            @e 'h1', 'Basic Example'

            # A simple paragraph with text
            @e 'p', 'Text from a template'

            # Text from a model
            @e 'p', model.get 'text'

            # A bound property will refresh its contents when the property in the model changes
            @e 'p', @bind model, 'autoUpdated'

            # This is a short form of
            @e 'p', ->
                @text @bind model, 'autoUpdated'

            # You can also use a function for the value of a bound property
            @e 'p', ->
                @text @bind model, 'autoUpdated', (newValue) ->
                    "This string was interpolated #{model.get 'autoUpdated'} times"

            # Not all tags need parameters
            @e 'br'

    # Render the template into our DOM element
    render: () -> ExampleView.template.renderInto @el, @model

# Export the view class
window.ExampleView = ExampleView
