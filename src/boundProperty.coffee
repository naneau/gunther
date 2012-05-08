# Bound property, a simple wrapper around the events the Backbone models fire
class BoundProperty

    # Constructor
    constructor: (@model, @propertyNames, @valueGenerator) ->
        # Default the value generator to a "get" of the property if we can
        if not @valueGenerator? and typeof @propertyNames is 'string'
            @valueGenerator = () => @model.get @propertyNames[0]

        # Make sure we have an array of property names (a string can be passed)
        @propertyNames = [].concat @propertyNames

        # Set up a listener for all the property names we need to watch
        for propertyName in @propertyNames
            @model.bind "change:#{propertyName}", () =>
                @trigger 'change', @getValue()

    # Get the value
    getValue: () ->
        generatedValue = @valueGenerator()
        if generatedValue instanceof Gunther.Template
            generatedValue.render()
        else
            generatedValue

    # Get value into a DOM element
    getValueInEl: (el) ->

        # Generate the value through the generator
        generatedValue = @valueGenerator()

        # If it is a child template, render it into el
        if generatedValue instanceof Gunther.Template
            generatedValue.renderInto el, @model

        # Render subview
        else if generatedValue instanceof Backbone.View
            generatedValue.setElement el
            generatedValue.render()

        # Simply set as HTML
        else
            if el.length > 0
                for element in el
                    element.textContent = generatedValue
            else
                el.textContent = generatedValue

# BoundProperty is an EventEmitter... (why can't I just extend from Backbone.Events?)
_.extend BoundProperty.prototype, Backbone.Events
