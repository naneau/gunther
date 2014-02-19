# Set up a subview for every item in the collection
Gunther.Template::itemSubView = (options, view = null) -> new ItemSubView options, view

# Create a list
Gunther.Template::list = (element, options, view = null) -> @element element, -> new ItemSubView options, view
