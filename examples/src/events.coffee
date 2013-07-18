# Example view with events
class ExampleView extends Backbone.View

    # Template with events
    @template: new Gunther.Template (model) ->

        # Nested section
        @e 'section', () ->

            # A header
            @e 'h1', 'Events'

            # Clickable link that shows the number of times it was clicked
            @e 'div', ->

                # Set up a click handler
                @on 'click', (e) -> model.set 'foo', (model.get 'foo') + 1

                @text @bind model, 'foo', () ->
                    "I was clicked #{model.get 'foo'} times"

    # View init
    initialize: () ->

        # Model with a simple numeric property
        @model = new Backbone.Model
            foo: 0

    # Render the template into our DOM element
    render: () -> ExampleView.template.renderInto @el, @model

# Export the view class
window.ExampleView = ExampleView

