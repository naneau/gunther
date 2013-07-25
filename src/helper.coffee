class Gunther.Helper
    # Create a DOM element
    #
    # Accepts simple class/id descriptors too, in the form of div.foo/div#foo
    @createHtmlElement: (description) ->
        # Tag name to create
        tagName = (description.match /([a-z0-9]+)([\.|\#]?)/i)[1]

        # Create the element
        element = $(document.createElement tagName)

        # Return if element name matches description (avoid further regexing)
        return element if tagName is description

        # Identifier (div#foo)
        id = description.match /\#(-?[_a-zA-Z]+[_a-zA-Z0-9-]*)+/i
        element.attr 'id', (id[0].substring 1) if id?

        # Any and all classes in the description (div.foo.bar)
        classes = description.match /\.(-?[_a-zA-Z]+[_a-zA-Z0-9-]*)/ig

        # Join up classes
        join = (memo, val) -> memo + ' ' + val.substring 1
        classNameFull = $.trim  _.reduce classes, join, ''

        # Set the class attr
        element.attr 'class', classNameFull

        # Return the element
        element
