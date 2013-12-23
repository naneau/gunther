test 'Lists', ->

  collection = new Backbone.Collection
  elem = singleElement 'div.list', collection, ->
    @list 'div.list', collection, new Gunther.Template (item) ->
      @element "div.item.#{item.get 'foo'}"

  equal elem.children().length, 0, 'List should initialize when empty'

  collection.add foo: 'bar', bar: 'baz1'

  equal elem.find('div.bar').length, 1, 'List should add a single items'

  collection.add foo: 'bar', bar: 'baz2'
  collection.add foo: 'bar', bar: 'baz1'
  collection.add foo: 'bar', bar: 'baz2'
  collection.add foo: 'bar', bar: 'baz1'

  equal elem.find('div.bar').length, 5, 'List should add a multiple items'

  collection.remove collection.first()
  equal elem.find('div.bar').length, 4, 'list should remove a single item'

  collection.remove collection.where bar: 'baz1'
  equal elem.find('div.bar').length, 2, 'list should remove a multiple item'

test 'Lists, non empty', ->

  # Init col. with 10 items
  collection = new Backbone.Collection
  for index in [0..10]
    collection.add
      foo:    'bar'
      bar:    'baz1'
      index:  x

  # List the items
  elem = singleElement 'div.list', collection, ->
    @list 'div.list', collection, new Gunther.Template (item) ->
      @element "div.item.#{item.get 'foo'}.index-#{item.get 'index'}"

  # Check init size
  equal elem.children().length, 10, 'List should initialize with right set of elements'

  # Add item
  collection.add foo: 'foo', bar: 'baz2', index: 10

  equal elem.find('div.bar').length, 10, 'List should add a single item'

  # Add some more items
  collection.add foo: 'foo', bar: 'baz2', index: 11
  collection.add foo: 'foo', bar: 'baz2', index: 12
  collection.add foo: 'foo', bar: 'baz2', index: 13

  equal elem.find('div.bar').length, 14, 'List should add a multiple items'

  # Remove last
  collection.remove collection.last()

  equal elem.find('div.bar').length, 13, 'list should remove a single item'

  # Removes 10 items
  collection.remove collection.where foo: 'bar'

  equal elem.find('div.bar').length, 3, 'list should remove a multiple item'
