# Set up the global "namespace" for Gunther to live in
Gunther = {
    # Partial renderers
    partials: {}

    # Add a partial
    addPartial: (key, partial) -> Gunther.partials[key] = partial
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
