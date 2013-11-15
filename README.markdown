# Gunther

[![Build Status](https://travis-ci.org/naneau/gunther.png?branch=master)](https://travis-ci.org/naneau/gunther)

## Introduction

Gunther is a view and templating tool for
[Backbone](http://backbonejs.org/). Its goal is to provide a powerful and
flexible way to create views, based on Backbone Models and Collections,
supporting live bindings and expressive syntax.

Gunther's templates are never compiled or interpreted. The templates are "live"
functions, that retain their parent scope. Because they are code based, not
string based, they are easily maintained with the rest of application code.

### Concise

Template are short, to the point, and easy to read. Gunther is written to make
maximum use [CoffeeScript's](http://coffeescript.org/) notation, combined with
CSS inspired element creation.

```coffeescript
template = new Gunther.Template (backboneModel) ->

    # Elements are added using the @element method
    @element 'p', 'This is some text'

    # The @element method accepts ID's, classes, attributes and properties in
    # a CSS-like syntax
    @element 'p#has-an-id'
    @element 'p.has-a-class'
    @element 'input[type=checkbox]:checked'

    # IDs, classes, attributes, and properties can be chained
    @element 'input[type=text]#foo.bar.baz:checked'

    # Children are added functionally
    @element 'p', ->
        @element 'a[href=linked.html]', -> 'This is a link'
        @element 'span', -> 'And this is some text in a span'

    # All content can be expressed as functions
    @text -> "I can count to 10! #{implode ',' [1..10]}"

    # Events can be handled inline, without losing scope
    @on 'click', (e) -> backboneModel.set foo: 'bar'
```

### Live Bindings

Gunther can bind any model attribute to DOM elements, classes, attributes and
properties, allowing for live updating views.

```coffeescript
template = new Gunther.Template (backboneModel) ->

    @element 'p', ->

        # Toggle a class depending on a model's attribute
        @toggleClass 'foo', backboneModel, 'foo'

        # Toggle a class using a generator
        @toggleClass 'bar', backboneModel, 'bar', () -> (backboneModel.get 'bar') is 'bar'

        # Bind text to a model's attribute
        @boundText backboneModel, 'foo'

        # Bind DOM attributes to a model
        @boundAttribute 'src' backboneModel, 'source'

        # Bind DOM properties to a model
        @boundProperty 'checked' backboneModel, 'selected'

        # Change a style property with a model's attribute
        @boundCss 'color', backboneModel, 'foo', () ->
            if (backboneModel.get 'foo') is 'foo' then '#FF0000' else '#0000FF'
```

### List views

List views allow you to set up repeated views for items from a collection. The
list is automatically pruned and sorted when the underlying collection is.

```coffeescript
template = new Gunther.Tempalte (collection) ->
    @list 'ul', collection, new Gunther.Template (item) ->
        @element 'li', -> item.get 'foo'
```

### Extensibility

Gunther supports partials, so it's easy to create re-usable components.
Templates can also be composed out of sub-templates.

```coffeescript

# A "fancy" paragraph partial
Gunther.addPartial 'fancyParagraph', (text) ->
    @element 'p.fancy', -> text

# A button partial, complete with handler
Gunther.addPartial 'button', (text, handler) ->
    @element 'button', ->
        @text text
        @on 'click', handler

template = new Gunther.Template (backboneCollection) ->

    # Fancy paragraph
    @fancyParagraph 'this is the text for the paragraph'

    # Button
    @button 'Click me!', () -> alert 'I was clicked!'

    # Render another template inside this one
    @subTemplate someOtherTemplate
```

## Rendering

Rendering a template is easy:

```coffeescript

template = new Gunther.Template ->
    @element 'div', 'This is text from a Gunther template'

template.renderInto $ '#your-element'
```

Gunther's templates integrate easily with Backbone's views:

```coffeescript

class FooView extends Backbone.View

    # The view's template
    @template: new Gunther.Template (model) ->
        @element 'div', -> model.get 'foo'

    # Use the render method to render the template into the view's element
    render: -> FooView.template.renderInto @$el, @model
```
