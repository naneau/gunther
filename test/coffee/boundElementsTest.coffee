module: 'Bound Elements'

# Elements rendering, core
test 'Binding', ->

  model = new Backbone.Model
    class: 'foo'

  template = new Gunther.Template (model) ->
    @element 'div.before'

    @boundElement 'div.wrapper', model, 'class', ->
      @element "div.#{model.get 'class'}"

    @element 'div.after'

  wrapper = renderGunther template, model

  equal wrapper.find('> div').length, 3, 'Bound element should render among siblings'

  # Wrapper element for the bound elem
  boundElement = wrapper.find '.wrapper'

  equal boundElement.children('.foo').length, 1, 'Bound element should initialize'

  # Change proeprty
  model.set 'class', 'bar'

  elem = deepEqual (wrapper.find '.wrapper'), boundElement, 'Parent element should not change'
  equal boundElement.children('.bar').length, 1, 'Bound element should change'
