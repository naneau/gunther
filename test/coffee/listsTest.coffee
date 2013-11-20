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
