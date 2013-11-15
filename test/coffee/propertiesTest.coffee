test 'Properties', ->

    elem = singleElement 'input', 'input[type=checkbox]:checked'
    equal (elem.prop 'checked'), true, 'Properties should be set from description'

    elem = singleElement 'input', -> @element 'input[type=checkbox]', ->
        @property 'checked', true
    equal (elem.prop 'checked'), true, 'Properties should be set from @property'

    elem = singleElement 'input', -> @element 'input[type=checkbox]', ->
        @property 'checked', false
    equal (elem.prop 'checked'), false, 'Properties should be set from @property'

test 'Properties, bound', ->

    model = new Backbone.Model foo: false

    elem = singleElement 'input', model, -> @element 'input[type=checkbox]', ->
        @boundProperty 'checked', model, 'foo'

    equal (elem.prop 'checked'), false, 'Properties should be initialized right from @boundProperty'
    model.set foo: true
    equal (elem.prop 'checked'), true, 'Properties should change with @boundProperty'
