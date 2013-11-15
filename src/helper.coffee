class Gunther.Helper
    # Create a DOM element
    #
    # Accepts simple class/id descriptors too, in the form of div.foo/div#foo
    @createHtmlElement: (description) ->

        # Description the string into relevant tokens
        tokens = _.filter (description.split /(?=\.)|(\[.+\=.+\])|(\:[a-z0-9]+)|(?=#)/), (t) -> t?

        # Make sure we get at least one token
        throw new Error "Invalid element description #{description}" unless tokens.length >= 1

        # Tag name to create
        tagName = tokens[0]

        # Sanity check for tag name
        throw new Error "Invalid tag name #{tagName}" unless /^[a-zA-Z0-9]+$/.test tagName

        # Create the element
        element = $(document.createElement tagName)

        # Return if element name matches description (avoid further regexing)
        return element if tagName is description

        # Parse remainder of tokens
        for token in tokens
            # ID
            if token[0] is '#'
                element.attr 'id', token.substr 1

            # Class
            else if token[0] is '.'
                element.attr 'class', (element.attr 'class') + ' ' + token.substr 1

            # Property, like :checked
            else if token[0] is ':'
                element.prop (token.substr 1), true

            # Attribute, like [foo=bar]
            else if token[0] is '[' and token[token.length = 1] = ']'

                # Split into parts
                attributeDefinition = ((token.substr 1).substr 0, token.length - 2).split '='

                # Make sure we get two parts as required
                continue if attributeDefinition.length isnt 2

                element.attr attributeDefinition[0], attributeDefinition[1]

        # Return the element
        element
