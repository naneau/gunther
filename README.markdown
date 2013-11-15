# Gunther

[![Build Status](https://travis-ci.org/naneau/gunther.png?branch=master)](https://travis-ci.org/naneau/gunther)

## Introduction

Gunther is a view and templating language for
[Backbone](http://backbonejs.org/). The goal is to provide an expressive, yet
powerful way to create views, based on Backbone Models and Collections.

Gunther is never compiled or interpreted. The templates are "live" functions.
You will not lose scope, and you can maintain the templates directly
inside/alongside your views. Any function you can call in your app's code you
can call from a template.

### Concise

Template are short, to the point, and easy to read. Gunther is written to make
maximum use [CoffeeScript's](http://coffeescript.org/) notation.

```coffeescript
template = new Gunther.Template ->

    # Add an element, and set it's contents
    @element 'p', 'This is some text'

    # @e is an alias for @element, you can pass classes and ids directly to it
    @e 'p.has-a-class', ->

        # Nest
        @e 'a', ->
            # Set attributes
            @attr 'href', '/something/fun'
            # Set text
            @text 'This is a link'
```

### Functional

All properties of elements can be expressed as a CoffeeScript function.

```coffeescript
template = new Gunther.Template (backboneModel) ->

    @e 'p', ->

        # Set an attribute
        @attr 'class', ->
            if (backboneModel.get 'someProperty') is 'something'
                'foo'
            else
                'bar'

        # Set some text
        @text ->
            text = ''
            text = text + x + ' ' for x in [0..10]
            text

        # Handle an event, directly from your template
        @on 'click', (e) -> backboneModel.set foo: 'bar'
```

### Centralized And Live

Because all properties can be expressed as functions, there is no need to write
logic *around* your views. You can simply use properties from your models
directly in your views, through bindings. No more wrapping functions and jQuery
searching for elements.

```coffeescript
template = new Gunther.Template (backboneModel) ->

    @e 'p', ->
        # Set a "color" property in your model and make it the background color
        # of an element
        @style 'background-color', @bind backboneModel, 'color', ->
            backboneModel.get 'color'

        # Bind some text to a property
        @text, @bind backboneModel, 'foo', ->
            if (backboneModel.get 'foo') is 'bar'
                'This is the text for bar'
            else
                'While this is the text for *not* bar'
```

### Extensible

Gunther supports partials, so it's easy to create re-usable components. It is
also possible to call include another template from inside template code.

```coffeescript

# Register a partial
Gunther.addPartial 'fancyParagraph', (text) ->
    @e 'p.fancy', -> text

template = new Gunther.Template (backboneCollection) ->

    # Fancy paragraph
    @partial 'fancyParagraph', 'this is the text for the paragraph'

    # Subtemplate
    @e 'p', -> @subTemplate someOtherTemplate

    # SubViews, for easy repetition
    # Subviews are bound to the collection's items, and will update accordingly
    @e 'ul', -> @itemSubView

        # Collection to use
        model: backboneCollection

        # Generator for the subview, creates a Gunther template
        # This template will be rendered for *every* item in the collection
        generator: (item) -> new Gunther.Template ->
            @e 'li', -> item.get 'foo'

```

## More

See the [examples](https://github.com/naneau/gunther/tree/master/examples).
