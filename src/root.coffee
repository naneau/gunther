# Set up the global "namespace" for Gunther to live in
Gunther = {}

# Export through CommonJS if we have a require function
# This is a tad hacky for now
#
if (typeof require)?
    module.exports = Gunther

    # Require underscore
    _ = require 'underscore'

    # Require backbone
    Backbone = require 'backbone'

else
    # Export Gunther to the global scope
    window.Gunther = Gunther

# Make sure we have underscore.js
throw 'Underscore.js must be loaded for Gunther to work' if (typeof _) is not 'function'
