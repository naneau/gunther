# Set up the global "namespace" for Gunther to live in
Gunther = {
    # Partial renderers
    partials: {}

    # Add a partial
    addPartial: (key, partial) ->

        # Set it up as a partial
        Gunther.partials[key] = partial

        # Register as a method on root
        throw new Error "Partial \"#{key}\" already exists" if Gunther.Template::[key]?

        # Register on template
        Gunther.Template::[key] = (args...) -> @partial.apply this, [key].concat args
}

# Export through CommonJS if we have a require function
# This is a tad hacky for now
#
if require?
    module.exports = Gunther

    # Require dependencies
    _ = require 'underscore'
    Backbone = require 'backbone'

else
    # Export Gunther to the global scope
    window.Gunther = Gunther

    # Require dependencies
    { _, Backbone } = window

# Make sure we have underscore.js
throw 'Underscore.js must be loaded for Gunther to work' if (typeof _) is not 'function'
