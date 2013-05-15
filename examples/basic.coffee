# Example view
class ExampleView extends Backbone.View

    # Simple template, renders an unordered list for every item
    @template: new Gunther.Template (model) ->

        # Nested section
        @e 'section', () ->

            # A header
            @e 'h1', 'Basic Example'

            # A simple paragraph with text
            @e 'p', 'Text from a template'

            # Text from a model
            @e 'p', model.get 'text'

            # A bound property will refresh its contents when the property in the model changes
            @div -> @bind model, 'autoUpdated'

            # Not all tags need parameters
            @e 'br'

    # Render the template into our DOM element
    render: () -> ExampleView.template.renderInto @el, @model

# Export the view class
window.ExampleView = ExampleView
