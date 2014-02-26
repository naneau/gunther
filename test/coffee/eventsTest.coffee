module 'Events'

# Elements rendering, core
asyncTest 'Handling', ->

  expect 1

  # Div with a click handler
  wrapper = renderGunther new Gunther.Template ->
    @element 'div', ->
      @on 'click', (e) ->
        ok true
        do start

  (wrapper.find 'div').trigger 'click'
