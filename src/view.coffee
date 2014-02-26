# Public: A view that uses Gunther.Template
#
# Use this class to easily create Backbone.Views that use Gunther's templating.
#
# Examples
#
#  class Foo extends Gunther.View
#    template: (model) ->
#      @p -> model.get 'foo'
class Gunther.View extends Backbone.View

  # Private: Wrap a template
  #
  # tpl: either a {Function} or {Gunther.Template}
  @wrapTemplate: (tpl) -> if typeof tpl is 'function' then new Gunther.Template tpl else tpl

  # Render
  render: () ->
    # Get the actual template
    template = Gunther.View.wrapTemplate @template

    # Sanity check
    throw new Error "No template given" if template not instanceof Gunther.Template

    # Render the template
    template.renderInto @$el
