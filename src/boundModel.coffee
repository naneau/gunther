# Bound property, a simple wrapper around the events the Backbone models fire
class BoundModel

    # Constructor
    constructor: (@model, @propertyName, templateAndArgs...) ->

        @template = do templateAndArgs.pop
        @args = templateAndArgs

        # If we are passed a function, that isn't a template, make it a template
        if @template instanceof Function and @template not instanceof Gunther.Template
            @template = new Gunther.Template @template

        # Store the current CID
        @currentCid = @model.cid

        # Listen to changes
        @model.bind "change:#{@propertyName}", (parent) =>

            model = parent.get @propertyName

            # No change
            return if model? and model.cid is @currentCid

            # New current CID
            if model? then @currentCid = model.cid else @currentCid = null

            # Trigger change
            @trigger 'change', model

    # Get value into a DOM element
    getValueInEl: (el) ->
        @template.renderInto.apply @template, [].concat el, (@model.get @propertyName), @args

# BoundModel is an EventEmitter... (why can't I just extend from Backbone.Events?)
_.extend BoundModel.prototype, Backbone.Events
