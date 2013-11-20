test 'Classes', ->

  elem = singleElement 'div', 'div.foo'
  equal (elem.hasClass 'foo'), true, 'Single class should be added'
  equal (elem.attr 'class'), 'foo', 'Only specified classes should be added'

  elem = singleElement 'div', 'div.foo.bar'
  equal (elem.hasClass 'foo'), true, 'Multiple classes should be added'
  equal (elem.hasClass 'bar'), true, 'Multiple classes should be added'
  equal (elem.hasClass 'bar'), true, 'Multiple classes should be added'
  equal (elem.attr 'class'), 'foo bar', 'Only specified classes should be added'

  elem = singleElement 'div', -> @element 'div.foo', -> @attr 'class', 'bar'
  equal (elem.hasClass 'foo'), false, 'Class can be overwritten'
  equal (elem.hasClass 'bar'), true, 'Class can be overwritten'

test 'Classes, toggle', ->

  model = new Backbone.Model bar: true
  elem = singleElement 'div', -> @element 'div.foo', -> @toggleClass 'bar', model, 'bar'

  equal (elem.hasClass 'foo'), true, '@toggleClass shouldn\'t remove default class'
  equal (elem.hasClass 'bar'), true, '@toggleClass should initialize its class right'

  model = new Backbone.Model bar: false
  elem = singleElement 'div', -> @element 'div.foo', -> @toggleClass 'bar', model, 'bar'

  equal (elem.hasClass 'foo'), true, '@toggleClass shouldn\'t remove default class'
  equal (elem.hasClass 'bar'), false, '@toggleClass should initialize its class right'

  model.set bar: true
  equal (elem.hasClass 'bar'), true, '@toggleClass should add its class'

  model.set bar: false
  equal (elem.hasClass 'bar'), false, '@toggleClass should remove its class'
