test 'Switch views', ->

  # Kept template
  templateKeep = new Gunther.Template () ->
    @element 'div.kept', -> 'I am kept'

  # Switched template
  templateSwitch = new Gunther.Template () ->
    @element 'div.switch', -> 'I am switched'

  # Switching template
  template = new Gunther.Template (state)->

    @switchView 'div.switched-wrapper', state, 'toggle', ->
      @keep templateKeep, state, (toggle) -> toggle
      @switch templateSwitch, state, (toggle) -> not toggle

  # State for the switched view
  state = new Backbone.Model toggle: true

  # Render it
  wrapper = renderGunther template, state

  equal (wrapper.find '.switched-wrapper').length, 1, 'Switched view should initialize its wrapping element'
  equal (wrapper.find 'div.kept').length, 1, 'Switched view should initialize with the right elements'
  equal (wrapper.find 'div.switch').length, 0, 'Switched view should initialize with the right elements'

  # Toggle state
  state.set 'toggle', false

  equal (wrapper.find 'div.kept').length, 1, 'Switched view should keep elements'
  ok !(wrapper.find 'div.kept').is(':visible'), 'Switched view should hide elements that it keeps'
  equal (wrapper.find 'div.switch').length, 1, 'Switched view should render new elements'

  # Toggle state back
  state.set 'toggle', true

  equal (wrapper.find 'div.kept').length, 1, 'Switched view should keep elements'
  equal (wrapper.find 'div.switch').length, 0, 'Switched view should remove "switch" elements'

  # Toggle state back once more
  state.set 'toggle', false

  equal (wrapper.find 'div.kept').length, 1, 'Switched view should keep elements'
  ok !(wrapper.find 'div.kept').is(':visible'), 'Switched view should hide elements that it keeps'
  equal (wrapper.find 'div.switch').length, 1, 'Switched view should render new elements'
