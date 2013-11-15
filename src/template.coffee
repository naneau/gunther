# Main template class
class Gunther.Template

    # additional DOM parsers, can be used to set up plugins, etc.
    @domParsers = []

    # Remove a partial
    @removePartial = (key) -> delete Gunther.Template.partials.key

    # Value for an element whereby both a function and a direct value can be passed
    # scope is optional
    @elementValue: (generator, scope = {}) ->
        return generator.apply scope if typeof generator is 'function'

        generator

    # Generate children for a DOM element
    @generateChildren: (el, childFn, scope) ->

        # Do the actual recursion, setting up the scope proper, and passing the parent element
        childResult = Gunther.Template.elementValue childFn, scope

        # Make sure we get a result in the first place
        return if childResult is undefined

        # If the child generator returns a string, we have to append it as a text element to the current element
        el.append document.createTextNode childResult if typeof childResult isnt 'object'

        # If we get a bound property or model, we set up the initial value, as well as a change watcher
        if childResult instanceof BoundProperty or childResult instanceof BoundModel

            # Initial generated value
            childResult.getValueInEl el

            # Track changes in the bound property
            childResult.bind 'change', (newVal) ->

                # Empty the node for updates
                el.empty()

                # Set the new value
                childResult.getValueInEl el

        # The child is a new View instance, we set up the proper element and render it
        else if childResult instanceof Backbone.View

            # Set the view's element to the current one
            childResult.setElement el

            # Render the view
            childResult.render()

    # Constructor
    constructor: (@fn) -> null

    # Render
    render: (args...) ->

        # Set up a root element, its children will be transferred
        @root = $ '<div />'

        # Current element, starts out as the root element, but will change in the tree
        @current = @root

        # Start the template function
        @fn.apply this, args

        # Add all children of root to the element we're supposed to render into
        children = @root.contents()

        # Parse dom with the DOM parsers
        for domParser in Gunther.Template.domParsers
            for child in children
                domParser child

        children

    # Render into an element
    #
    # Will return a Backbone.View that can be used/modified to your wishes
    renderInto: (el, args...) ->

        # Append a child for every element @render returns
        ($ el).append child for child in @render args...

        # Return a view
        new Backbone.View
            el: ($ el)

    # Add text to the current element
    #
    # This will create a text node and append it to the current element, the
    # contents of which can be either a string, or a bound property (see
    # @bind())
    text: (text) ->

        # Create text node
        el = document.createTextNode ''

        # Set the contents of the child node
        if typeof text is 'string'
            el.nodeValue = text
        else
            # Get value for child result
            childResult = Gunther.Template.elementValue text, this

            # If we get a bound property, we set up the initial value, as well as a change watcher
            if childResult instanceof BoundProperty
                el.nodeValue = childResult.getValue()
                childResult.bind 'change', (newVal) ->
                    el.nodeValue = newVal

            # If not, we just set the result as the value
            else
                el.nodeValue = childResult

        # Append the child node
        @current.append el

    # Bound text
    boundText: (args...) -> @text new BoundProperty args...

    # Spaced text
    spacedText: (text) -> @text " #{text} "

    # Create a child to @current, recurse and add children to it, etc.
    element: (tagName, args...) ->

        # Element we're working on starts out with the current one set up in
        # the "this" scope. This will change in the child rendering, so we need
        # to retain a reference
        current = @current

        # Element to render in
        el = Gunther.Helper.createHtmlElement tagName

        # Change current element to the newly created one for our children
        @current = el

        # The last argument
        lastArgument = args[args.length - 1]

        # We have to recurse, if the last argument passed is a function
        if typeof lastArgument is 'function'
            Gunther.Template.generateChildren el, args.pop(), this

        # Bound property or model passed?
        else if lastArgument instanceof BoundProperty or lastArgument instanceof BoundModel
            Gunther.Template.generateChildren el, args.pop(), this

        # If we get passed a string as last value, set it as the node value
        else if typeof lastArgument is 'string'
            el.append document.createTextNode args.pop()

        # Append it to the current element
        current.append el

        # Set the now current again element in the this scope
        @current = current

        null

    # Set up an element which is bound to a model's property
    boundElement: (args...) -> @element (do args.shift), new BoundModel args...

    # Set an attribute
    attribute: (name, value, args...) ->

        # Current element
        el = @current

        # Set up binding for bound properties
        if value instanceof BoundProperty

            # Set the base value
            el.attr name, value.getValue()

            # On change re-set the attribute
            value.bind 'change', (newValue) -> el.attr name, value.getValue()

        # Else try to set directly
        else
            el.attr name, value

        null

    # Add up an attribute which is "bound"
    # Pass it the attributes name, the model, the property, and optionally a
    # value generating function
    boundAttribute: (args...) -> @attribute (do args.shift), new BoundProperty args...

    # Set a property (note this differs from attributes, as per jQuery's API)
    property: (name, value, args...) ->

        # Current element
        el = @current

        # Set up binding for bound properties
        if value instanceof BoundProperty

            # Set the base value
            el.prop name, value.getValue()

            # On change re-set the property
            value.bind 'change', (newValue) -> el.prop name, value.getValue()

        # Else try to set directly
        else
            el.prop name, value

        null

    # Add up a property which is "bound"
    # Pass it the property's name, the model, the property, and optionally a
    # value generating function
    boundProperty: (args...) -> @property (do args.shift), new BoundProperty args...

    # Set a style property
    css: (name, value) ->

        # When hash is passed, run each item through @css
        return (@css realName, value for realName, value of name) if name instanceof Object

        # Current element
        el = @current

        # Set up binding for bound properties
        if value instanceof BoundProperty

            # Set the base value
            el.css name, value.getValue()

            # On change re-set the attribute
            value.bind 'change', (newValue) -> el.css name, newValue

            return el

        # Else try to set directly
        else
            el.css name, value

        null

    # Bound CSS property
    boundCss: (args...) -> @css (do args.shift), new BoundProperty args...

    # Show/hide an element based on a boolean property
    show: (model, properties, resolver) ->

        # Hold on to current element
        element = @current

        # Initialize resolver when not passed
        (resolver = (value) -> value) unless resolver?

        # The actual show method
        show = (element, shown) -> if shown then do ($ element).show else do ($ element).hide

        for property in [].concat properties
            do (property) =>

                # Track changes
                model.on "change:#{property}", (model) ->
                    show element, resolver model.get property

                # Initial show/hide
                show element, resolver model.get property

    # Hide/show an element based on a boolean property
    # This is simply show() inverted
    hide: (model, properties, resolver) ->

        # Initialize resolver when not passed
        (resolver = (value) -> value) unless resolver?

        @show model, properties, (value) -> not resolver value

    # Toggle a class
    toggleClass: (className, model, properties, toggle) ->

        # Make sure we get an array of props
        properties = [].concat properties

        # When no toggle is passed simply use a property value
        unless toggle instanceof Function then toggle = (value) -> value

        # Track the element
        element = @current

        # Perform the class toggle
        performToggle = (model, value) ->
            ($ element).toggleClass className, toggle value

        # For every property in the list
        for property in properties

            model.on "change:#{property}", performToggle

            performToggle model, model.get property

        null

    # Set up an event handler for DOM events
    on: (event, handler) -> @current.bind event, handler

    # A "halted" on, that has no propagation (and no default)
    haltedOn: (event, handler) -> @current.bind event, (event) ->
        do event.stopPropagation
        do event.preventDefault

        handler event

    # Append an element
    append: (element) ->
        if element instanceof Backbone.View
            # The element is a Backbone view

            # Render it
            element.render()

            # Append its element
            @current.append element.el

        else
            # Assume it can be appended directly
            @current.append element

    # Render a sub-template
    subTemplate: (template, args...) -> template.renderInto @current, args...

    # Render a registered partial
    partial: (key, args...) ->

        # Sanity check
        throw new Error "Partial \"#{key}\" does not exist" if not Gunther.partials[key]?

        template = new Gunther.Template Gunther.partials[key]

        @subTemplate.apply this, [template].concat args

    # Bind an attribute or property to a property of a model
    bind: (args...) -> new BoundProperty args...

    # Register a change handler for a model
    onModel: (model, event, handler) ->
        current = @current

        model.on event, (args...) -> handler.apply this, [current].concat args

    # Set up a subview for every item in the collection
    itemSubView: (options, view = null) -> new ItemSubView options, view

    # Create a list
    list: (element, options, view = null) -> @element element, -> new ItemSubView options, view

    # Aliases for shorter notation

    # Alias for element
    e: (tagName, args...) -> @element tagName, args...

    # Alias for add text
    t: (args...) -> @text args...

    # Attribute
    attr: (args...) -> @attribute.apply this, args
    a: (args...) -> @attribute.apply this, args

    # Property
    prop: (args...) -> @property.apply this, args

    # Shorthand for class
    class: (className) -> @attribute 'class', className

    # Partial
    p: (args...) -> @partial.apply this, args
