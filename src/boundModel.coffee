# Bind a full element to a model's property
class BoundModel

    # Constructor
    constructor: (@model, @propertyName, templateAndArgs...) ->

        @template = do templateAndArgs.pop
        @args = templateAndArgs

        # If we are passed a function, that isn't a template, make it a template
        if typeof @template is 'function' and @template not instanceof Gunther.Template
            @template = new Gunther.Template @template

        # Store the current value
        @currentValue = @model.get @propertyName

        # Listen to changes
        @model.bind "change:#{@propertyName}", (parent) =>

            # The new value
            newValue = parent.get @propertyName

            # Make sure there's actual change
            return if newValue is @currentValue

            # Store the current value
            @currentValue = newValue

            # Trigger change
            @trigger 'change', newValue

    # Get value into a DOM element
    getValueInEl: (el) ->
        @template.renderInto.apply @template, [].concat el, (@model.get @propertyName), @args

# BoundModel is an EventEmitter... (why can't I just extend from Backbone.Events?)
_.extend BoundModel.prototype, Backbone.Events
