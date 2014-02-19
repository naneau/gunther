module 'Lists'

runTests = (tests) ->

  # Stack the tests with the animation frames for Gunther's lists
  runningTest = 0
  next = ->
    # Last run
    return do start if runningTest is tests.length

    do tests[runningTest]

    runningTest++

    # Skip an animation frame for every test
    Gunther.Helper.animationFrame next

  do next

addAndRemoveTest = ->
  expect 5

  # Simple collection
  collection = new Backbone.Collection

  # Render the template
  elem = singleElement 'div.list', collection, ->
    @list 'div.list', collection, new Gunther.Template (item) ->
      @element "div.item.#{item.get 'foo'}"

  # Start with no items
  equal elem.children().length, 0, 'List should initialize when empty'

  tests = []
  tests.push ->
    collection.add foo: 'bar', bar: 'baz1'
  tests.push ->
    #console.log (elem.find 'div.bar')
    equal (elem.find 'div.bar').length, 1, 'List should add a single item'

  tests.push ->
    collection.add foo: 'bar', bar: 'baz2'
    collection.add foo: 'bar', bar: 'baz1'
    collection.add foo: 'bar', bar: 'baz2'
    collection.add foo: 'bar', bar: 'baz1'
  tests.push ->
    equal elem.find('div.bar').length, 5, 'List should add multiple items'

  tests.push ->
    collection.remove collection.first()
  tests.push ->
    equal elem.find('div.bar').length, 4, 'list should remove a single item'

  tests.push ->
    collection.remove collection.where bar: 'baz1'
  tests.push ->
    equal elem.find('div.bar').length, 2, 'list should remove multiple items'

  runTests tests

# This test is run twice to ensure there's no initializing/ID problems
asyncTest 'Adding And Removing Items', addAndRemoveTest
asyncTest 'Adding And Removing Items, repeat', addAndRemoveTest

asyncTest 'Lists, non empty', ->

  expect 5

  # Init col. with 10 items
  collection = new Backbone.Collection
  for index in [0..9]
    collection.add
      foo:    'bar'
      bar:    'baz1'
      index:  index

  # List the items
  elem = singleElement 'div.list', collection, ->
    @list 'div.list', collection, new Gunther.Template (item) ->
      @element "div.item.#{item.get 'foo'}.index-#{item.get 'index'}"

  tests = []

  # Check init size
  tests.push ->
    equal elem.children().length, 10, 'List should initialize with right set of elements'

  # Add item
  tests.push ->
    collection.add foo: 'foo', bar: 'baz2', index: 10
  tests.push ->
    equal elem.find('div.item.foo').length, 1, 'List should add a single item'

  # Add some more items
  tests.push ->
    collection.add foo: 'foo', bar: 'baz2', index: 11
    collection.add foo: 'foo', bar: 'baz2', index: 12
    collection.add foo: 'foo', bar: 'baz2', index: 13
  tests.push ->
    equal elem.find('div.item.foo').length, 4, 'List should add multiple items'

  # Remove last
  tests.push ->
    collection.remove collection.last()
  tests.push ->
    equal elem.find('div.item.foo').length, 3, 'list should remove a single item'

  # Removes 10 items
  tests.push ->
    collection.remove collection.where foo: 'bar'
  tests.push ->
    equal elem.find('div.item.foo').length, 3, 'list should remove multiple items'

  runTests tests

# Large listing
asyncTest 'Lists, large item counts', ->
  expect 1

  # Init col. with 10 items
  collection = new Backbone.Collection

  # List the items
  elem = singleElement 'div.list', collection, ->
    @list 'div.list', collection, new Gunther.Template (item) ->
      @element "div.item.#{item.get 'foo'}.index-#{item.get 'index'}", ->
        @t item.get 'index'

  maxNumRuns = 100
  multiplier = 10
  add = (runCount) ->

    # Add item
    for x in [0..(multiplier - 1)]
      collection.add
        foo:    'bar'
        index:  runCount + '.' + x

    # When max is reached, check result
    return check (maxNumRuns * multiplier) if runCount is (maxNumRuns - 1)

    # Next run
    add runCount + 1

  check = (count) -> Gunther.Helper.animationFrame ->

    # Ensure removal worked
    equal elem.find('div.item.bar').length, count, "List should have #{count} items in the end"

    # Start rest of tests
    do start

  add 0

