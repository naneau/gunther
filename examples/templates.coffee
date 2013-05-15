text = new Gunther.Template (model)->

    # A simple paragraph with text
    @e 'p', 'this is just a text node'

    # A div with children
    @e 'div', () ->

        # Property
        @prop 'class', 'foo'

        # Text
        @e 'p', 'a child node that is text'

        # Text from a model
        @e 'p', model.get 'textProperty'

events = new Gunther.Template (model) ->

    # A link with an event handler
    @e 'a', ->

        # Event handler
        @on 'click', (event) ->
            event.stopPropagation()

            alert 'Clickity'

        # Text of the link
        @text 'the text for this node'

bindings = new Gunther.Template (model) ->

    # Paragraph with a bound text
    @e 'p', @bind model, 'propertyName'

    # Div with a bound property
    @e 'div', () ->
        @prop 'class', @bind model, 'propertyName', (newValue) ->
            if newValue is 'x' then 'class-for-x' else 'class-for-not-x'

    # Input that changes when a property changes, but also changes the
    # property when the input is changed by the user
    @e 'input', () ->
        @prop 'value', @doubleBind model, 'propertyName'

# Style properties
styleProperties = new Gunther.Template (model) ->

    @e 'div', () ->

        # Display bound to a property
        @boundStyle 'display', model, 'propertyName', (newValue, element) ->
            if newValue is 'awesome' then 'block' else 'none'

# Sub-template
subTemplates = new Gunther.Template (collection) ->

    @e 'ul', @collection collection, subTemplate

# The actual sub-template
subTemplate = new Gunther.Template (model) ->
    @e 'li', model.get 'textProperty'


# A backbone.js view using Gunther
class View extends new Backbone.View

    # Initialize
    initialize: () ->

        # Initialize some model
        @model = new Backbone.Model

    # Rendering into @el from Backbone through
    render: () ->
        template.renderInto @el, @model
