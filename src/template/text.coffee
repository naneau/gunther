### Public ###
#
# Add text to the current element
#
# This will create a text node and append it to the current element
#
# text - {String} the text to add
Gunther.Template::text = (text) ->

  # Create text node
  el = document.createTextNode ''

  # Set the contents of the child node
  if typeof text is 'string'
    el.nodeValue = text
  else
    # Get value for child result
    childResult = Gunther.Template.elementValue text, this

    # If we get a bound property, we set up the initial value, as well as a change watcher
    if childResult instanceof BoundProperty
      el.nodeValue = childResult.getValue()
      childResult.bind 'change', (newVal) ->
        el.nodeValue = newVal

    # If not, we just set the result as the value
    else
      el.nodeValue = childResult

  # Append the child node
  @current.append el

# Bind a text node to a model's property
#
# model - {Backbone.Model} to bind on
# property - {String} or {Array} of properties to bind on
# generator - (optional) method that generates the value after a change, when
#   omitted, the value of the changed property is used
Gunther.Template::boundText = (args...) -> @text new BoundProperty args...

# Add text, with spaces on either side
#
# {Gunther.Template::text} adds its text node without whitespace surrounding
# it, which is sometimes not desired for stylistic reasons. This method will
# add the text surrounded by a space on either side.
#
# text - {String} Text to add
Gunther.Template::spacedText = (text) -> @text " #{text} "
