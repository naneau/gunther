# Elements rendering, core
module 'Initialization'

# Tags
test 'tags', ->

  # Three div's in a row, without a root element
  wrapper = renderGunther new Gunther.Template ->
    @div 'foo'
    @p 'foo'
    @a 'foo'

  equal wrapper.children().length, 3, 'Root elements should render in correct number'
  equal wrapper.children()[0].tagName, 'DIV', 'Element should render as correct type'
  equal wrapper.children()[0].innerHTML, 'foo', 'Element should get text'
  equal wrapper.children()[1].tagName, 'P', 'Element should render as correct type'
  equal wrapper.children()[2].tagName, 'A', 'Element should render as correct type'
