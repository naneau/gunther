# Switched views
#
# Set up a switched view
#@switchView 'div.switched', state, 'toggle', ->
    #@keep templateKeep, state, (toggle) -> toggle
    #@switch templateSwitch, state, (toggle) -> not toggle
    #
Gunther.Template::switchView = (element, model, properties, generator) ->
    @element element, ->
        return new SwitchedView @current, model, properties, generator

class SwitchedView
    switches: []

    # Constructor
    #
    # Expects the parent DOM element, the model/attributes to watch for and a
    # generator method that sets up the switching
    constructor: (@parent, @model, @attributeName, generator) ->
        # Set up change handlers
        @model.on "change:#{@attributeName}", => do @render

        # Actual specification for the switch
        generator.apply this, [@model]

    # Decided active switch and render
    render: ->

        # Make old active switch unactive
        @active.makeUnActiveIn @parent if @active?

        # Find the new active switch
        @active = _.find @switches, (viewSwitch) => viewSwitch.isActive @model.get @attributeName

        # Make it active
        @active.makeActiveIn @parent

    keep: (template, args...) ->
        @switches.push new ViewSwitch ViewSwitch.KEEP, template, args...

    switch: (template, args...) ->
        @switches.push new ViewSwitch ViewSwitch.SWITCH, template, args...

# Single switch
class ViewSwitch

    @KEEP: 'keep'
    @SWITCH: 'switch'

    isActive: false

    constructor: (@type, @template, args...) ->

        # Switch method
        @determinator = do args.pop

        # Left over arguments for tempalte
        @arguments = args

    # Determinate whether this switch is active or not
    isActive: (value) -> @determinator value

    # Make this ViewSwitch active in a DOM element
    makeActiveIn: (element) ->

        # If this view has been active before, simply show the hidden elements again
        if @switchedElements?
            do @switchedElements.show

        # If not, render the template
        else
            @switchedElements = @template.renderInto.apply @template, [element].concat @arguments

    # Make this ViewSwitch unactive
    makeUnActiveIn: (element) ->

        # If this is a kept switch, hide the elements
        if @type is ViewSwitch.KEEP
            do @switchedElements.hide

        # If it's not, destroy them
        else
            do @switchedElements.remove

            @switchedElements = null

# Export to Gunther scope
Gunther.SwitchedView = SwitchedView
