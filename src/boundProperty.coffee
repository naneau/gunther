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

# BoundProperty is an EventEmitter... (why can't I just extend from Backbone.Events?)
_.extend BoundProperty.prototype, Backbone.Events
