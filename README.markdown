# Gunther

[http://naneau.net/gunther](http://naneau.net/gunther)

[![Build Status](https://travis-ci.org/naneau/gunther.png?branch=master)](https://travis-ci.org/naneau/gunther)

## Introduction

Gunther is a view and templating tool for
[Backbone](http://backbonejs.org/). Its provides a powerful and flexible way to
create views, based on Backbone Models and Collections, supporting live
bindings and expressive syntax.

Gunther's templates are never compiled or interpreted. The templates are "live"
functions, that retain their parent scope. Because they are based in code, not
interpreted strings, they are easily maintained with the rest of application
code.

### Concise

The templates are based on a simple DSL. Gunther is written to make maximum use
[CoffeeScript's](http://coffeescript.org/) notation, combined with CSS inspired
element creation.

```coffeescript

template = new Gunther.Template ->

  # Elements are created using a simple DSL
  @div ->
      @p 'This is some text'
      @p 'This is some more text'

  # For more fine-grained creation, you can use @element()
  # This method accepts ID's, classes, attributes and properties in a
  # CSS-like syntax
  @element 'p#has-an-id'
  @element 'p.has-a-class'
  @element 'input[type=checkbox]:checked'

  # IDs, classes, attributes, and properties can be chained
  @element 'input[type=checkbox]#foo.bar.baz:checked'

  # Content can be expressed functionally
  @text -> "I can count to 10! #{implode ',' [1..10]}"

  # Events can be handled inline, without losing scope
  @on 'click', (e) -> someModel.set foo: 'bar'
```

### Live Bindings

Gunther can bind any model attribute to DOM elements, classes, attributes and
properties, allowing for live updating views.

```coffeescript
template = new Gunther.Template (model) ->
  @div, ->
    # Toggle a class depending on a model's attribute
    @toggleClass 'foo', model, 'foo'

    # Toggle a class using a generator
    @toggleClass 'bar', model, 'bar', () -> (model.get 'bar') is 'bar'

    # Bind text to a model's attribute
    @boundText model, 'foo'

    # Bind DOM attributes to a model
    @boundAttribute 'src' model, 'source'

    # Bind DOM properties to a model
    @boundProperty 'checked' model, 'selected'

    # Change a style property with a model's attribute
    @boundCss 'color', model, 'foo', () ->
      if (model.get 'foo') is 'foo' then '#FF0000' else '#0000FF'
```

### List views

List views allow you to set up repeated views for items from a collection. The
list is automatically pruned and sorted when the underlying collection is
modified.

```coffeescript
template = new Gunther.Template (collection) ->
  @list 'ul', collection, (item) ->
    @li item.get 'foo'
```

### Extensibility

Gunther supports partials, so it's easy to create re-usable components.
Templates can also be composed out of sub-templates.

```coffeescript

# A button partial, complete with handler
Gunther.addPartial 'button', (text, handler) ->
  @a ->
    @text text
    @on 'click', handler

template = new Gunther.Template ->

  # Button
  @button 'Click me!', () -> alert 'I was clicked!'

  # Render another template inside this one
  @subTemplate someOtherTemplate
```

## Rendering

Rendering a template is easy:

```coffeescript

template = new Gunther.Template ->
  @div 'This is text from a Gunther template'

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
