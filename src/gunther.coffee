# Set up the global "namespace" for Gunther to live in
Gunther = {}

# Main template class
class Gunther.Template

    # Create a DOM element
    @createHtmlElement: (tagName) -> $("<#{tagName} />")

    # Add attributes to a DOM element
    @addAttributes: (el, attributes) ->
        # For every attribute object set
        for attribute in attributes
            for attributeName, attributeValue of attribute

                # Bind events
                if _.include Gunther.HTML.eventNames, attributeName
                    el.bind attributeName, (args...) ->
                        attributeValue args...

                # See if we get a BoundProperty, which we bind to (and set)
                else if attributeValue instanceof BoundProperty
                    # Set the base attribute
                    el.attr attributeName, attributeValue.getValue()
                    # On change re-set the attribute
                    attributeValue.bind 'change', (newValue) -> el.attr attributeName, newValue

                # Else try to set directly
                else
                    el.attr attributeName, attributeValue

    # Generate children for a DOM element
    @generateChildren: (el, childFn, scope) ->
        # Do the actual recursion
        childResult = childFn.apply scope

        # If the child generator returns a string, we have to append it as a
        # text element to the current element
        el.append childResult if typeof childResult isnt 'object'

        # If we get a bound property, we set up the initial value, as well as a
        # change watcher
        if childResult instanceof BoundProperty
            el.html childResult.getValue()
            childResult.bind 'change', (newVal) ->
                el.html newVal

        # The child is a new View instance, we set up the proper element and render it
        else if childResult instanceof Backbone.View
            childResult.el = el
            childResult.render()

    # Constructor
    constructor: (@fn) -> null

    # Render
    render: (args...) ->
        # Set up a root element, its children will be conferred
        @root = $('<div />')

        # Current element, starts out as the root element, but will change in the tree
        @current = @root

        # Start the template function
        @fn.apply this, args

        # Add all children of root to the element we're supposed to render into
        @root.children()
        # Do we remove them from root afterwards?
        #@root.remove()

    # Render
    renderInto: (el, args...) ->
        el.append child for child in @render args...

    # Create a child to @current, recurse and add children to it, etc.
    createChild: (tagName, args...) ->
        # Element we're working on starts out with the current one set up in
        # the this scope, but will change in the child, so we keep a copy here
        current = @current

        # Element to render in
        el = Gunther.Template.createHtmlElement tagName

        # Change current element to the newly created one for our children
        @current = el

        # We have to recurse, if the last argument passed is a function
        Gunther.Template.generateChildren el, args.pop(), this if typeof args[args.length - 1] is 'function'

        # Set up the attributes for the element
        Gunther.Template.addAttributes el, args

        # Append it to the current element
        current.append el

        # Set the now current again element in the this scope
        @current = current

        null

    # Bind to a property of a model
    bind: (args...) -> new BoundProperty args...

# HTML information
class Gunther.HTML

    # All HTML5 elements :)
    # For each element in this set a function will be created on Gunther's prototype
    @elements = ["a", "abbr", "address", "article", "aside", "audio", "b",
        "bdi", "bdo", "blockquote", "body", "button", "canvas", "caption", "cite",
        "code", "colgroup", "datalist", "dd", "del", "details", "dfn", "div", "dl",
        "dt", "em", "fieldset", "figcaption", "figure", "footer", "form", "h1",
        "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup", "html", "i",
        "iframe", "ins", "kbd", "label", "legend", "li", "map", "mark", "menu",
        "meter", "nav", "noscript", "object", "ol", "optgroup", "option", "output",
        "p", "pre", "progress", "q", "rp", "rt", "ruby", "s", "samp", "script",
        "section", "select", "small", "span", "strong", "style", "sub", "summary",
        "sup", "table", "tbody", "td", "textarea", "tfoot", "th", "thead", "time",
        "title", "tr", "u", "ul", "video", "area", "base", "br", "col", "command",
        "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source",
        "track", "wbr", "applet", "acronym", "bgsound", "dir", "frameset",
        "noframes", "isindex", "listing", "nextid", "noembed", "plaintext", "rb",
        "strike", "xmp", "big", "blink", "center", "font", "marquee", "multicol",
        "nobr", "spacer", "tt", "basefont", "frame"]

    # List of default HTML Events
    # should be easy enough to extend with custom events
    @eventNames: ['load', 'unload', 'blur', 'change', 'focus', 'reset',
        'select', 'submit', 'abort', 'keydown', 'keyup', 'keypress', 'click',
        'dblclick', 'mousedown', 'mouseout', 'mouseover', 'mouseup']

# Set up all HTML elements as functions
for htmlElement in Gunther.HTML.elements
    do (htmlElement) -> # gotta love for...do :)
        Gunther.Template::[htmlElement] = (args...) ->
            @createChild htmlElement, args...

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

# Export Gunther to the global scope
window.Gunther = Gunther
