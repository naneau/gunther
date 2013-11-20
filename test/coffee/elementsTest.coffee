# Elements rendering, core
test 'Elements', ->

  elem = singleElement 'div', 'div'
  equal elem[0].tagName, 'DIV', 'Element should render as correct type'
  equal elem.contents().length, 0, 'Empty element should be empty'

  elem = singleElement 'p', 'p'
  equal elem[0].tagName, 'P', 'Element should render as correct type'
  equal elem.contents().length, 0, 'Empty element should be empty'

  elem = singleElement 'div', -> @element 'div', -> @text 'foo'
  equal elem[0].tagName, 'DIV', 'Element should render as correct type'
  equal elem.contents().length, 1, 'Non empty element should be not empty'
  equal elem.contents().first().text(), 'foo', 'Text should render inside of an element'

  # Three div's in a row, without a root element
  wrapper = renderGunther new Gunther.Template ->
    @element 'div'
    @element 'div'
    @element 'div'

  equal wrapper.children().length, 3, 'Root elements should render in correct number'
  equal wrapper.children()[0].tagName, 'DIV', 'Element should render as correct type'
  equal wrapper.children()[1].tagName, 'DIV', 'Element should render as correct type'
  equal wrapper.children()[2].tagName, 'DIV', 'Element should render as correct type'

test 'Elements, children', ->
  elem = singleElement 'div', ->
    @element 'div', ->
      @element 'div'
      @element 'p'
      @element 'span'
      @text 'foo'
      @element 'div'

  equal elem[0].tagName, 'DIV', 'Element should render as correct type'
  equal elem.contents().length, 5, 'There should be five children'
  equal elem.contents()[0].tagName, 'DIV', 'Children should be of correct type'
  equal elem.contents()[1].tagName, 'P', 'Children should be of correct type'
  equal elem.contents()[2].tagName, 'SPAN', 'Children should be of correct type'
  equal elem.contents()[3].nodeValue, 'foo', 'Text should render next to children'
  equal elem.contents()[4].tagName, 'DIV', 'Children should be of correct type'

test 'Elements, children of children', ->
  elem = singleElement 'div', ->
    @element 'div', ->
      @element 'section', ->
        @element 'span', -> 'foo'
      @element 'p', ->
        @element 'a[foo=bar]'

  equal elem[0].tagName, 'DIV', 'Element should render as correct type'
  equal elem.find('> section,p').length, 2, 'There should be two children'
  equal elem.find('> section > span').length, 1, 'Children of children should be of correct type'
  equal elem.find('> p > a').length, 1, 'Children of children should be of correct type'
