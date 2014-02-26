# Partials
Gunther.partials = {}

# Public: Add a partial
#
# key - {String} name of the partial
# handler - {Function} method to execute when partial is to be rendered
Gunther.addPartial = (key, handler) ->

  # Set it up as a partial
  Gunther.partials[key] = handler

  # Register as a method on root
  throw new Error "Can not add partial \"#{key}\", a partial or method with that name already exists" if Gunther.Template::[key]?

  # Register on template
  Gunther.Template::[key] = (args...) -> @partial.apply this, [key].concat args

# Public: Remove a partial
#
# See {Gunther::addPartial}
#
# key - {String} name of the partial
Gunther.removePartial = (key) -> delete Gunther.partials.key

# Public: Render a registered partial
#
# Arguments after `key` are passed directly to the partial's handler
#
# key - {String} name of the partials
Gunther.Template::partial = (key, args...) ->

  # Sanity check
  throw new Error "Partial \"#{key}\" does not exist" if not Gunther.partials[key]?

  template = new Gunther.Template Gunther.partials[key]

  @subTemplate.apply this, [template].concat args
