test 'Attributes', ->

  elem = singleElement 'div', 'div[foo=bar]'

  equal (elem.attr 'foo'), 'bar', 'Attributes should be set'
  equal elem.contents().length, 0, 'There should not be content in an empty node'

test 'Bound attributes', ->

  model = new Backbone.Model
  model.set 'foo', 'bar'

  elem = singleElement 'div', ->
    @element 'div', ->
      @boundAttribute 'foo', model, 'foo'

  equal (elem.attr 'foo'), 'bar', 'Attributes should be set'
  equal elem.contents().length, 0, 'There should not be content in an empty node'
  model.set 'foo', 'baz'
  equal (elem.attr 'foo'), 'baz', 'Attributes should change when the underlying model does'
