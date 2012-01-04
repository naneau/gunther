# Set up the global "namespace" for Gunther to live in
Gunther = {}

# Export Gunther to the global scope
window.Gunther = Gunther

# Export through CommonJS if we have a require function
# This is a tad hacky for now
module.exports = Gunther if (typeof require)?
