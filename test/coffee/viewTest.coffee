# Elements rendering, core
module 'View'

# Tags
test 'rendering', ->
  # Test view
  class TestView extends Gunther.View
    template: ->
      @div 'foo'
      @p 'foo'
      @a 'foo'

  t = new TestView

  wrapper = renderGuntherView t

  equal wrapper.children().length, 3, 'Root elements should render in correct number'
  equal wrapper.children()[0].tagName, 'DIV', 'Element should render as correct type'
  equal wrapper.children()[1].tagName, 'P', 'Element should render as correct type'
  equal wrapper.children()[2].tagName, 'A', 'Element should render as correct type'
