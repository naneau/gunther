# Partials
Gunther.partials = {}

# Add a partial
Gunther.addPartial = (key, partial) ->

  # Set it up as a partial
  Gunther.partials[key] = partial

  # Register as a method on root
  throw new Error "can not add partial \"#{key}\", a partial or method with that name already exists" if Gunther.Template::[key]?

  # Register on template
  Gunther.Template::[key] = (args...) -> @partial.apply this, [key].concat args

# Remove a partial
Gunther.removePartial = (key) -> delete Gunther.partials.key

# Render a registered partial
Gunther.Template::partial = (key, args...) ->

  # Sanity check
  throw new Error "Partial \"#{key}\" does not exist" if not Gunther.partials[key]?

  template = new Gunther.Template Gunther.partials[key]

  @subTemplate.apply this, [template].concat args
