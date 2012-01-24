# Set up the global "namespace" for Gunther to live in
Gunther = {}

# Export through CommonJS if we have a require function
# This is a tad hacky for now
#
if (typeof require)?
    module.exports = Gunther
else
    # Export Gunther to the global scope
    window.Gunther = Gunther
