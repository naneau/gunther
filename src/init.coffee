# List of HTML5 tags
Gunther.html5Tags = ["a", "abbr", "address", "area", "article", "aside", "audio", "b",
  "base", "bdi", "bdo", "blockquote", "body", "br", "button", "canvas",
  "caption", "cite", "code", "col", "colgroup", "data", "datagrid", "datalist",
  "dd", "del", "details", "dfn", "dialog", "div", "dl", "dt", "em", "embed",
  "eventsource", "fieldset", "figcaption", "figure", "footer", "form", "h1",
  "h2", "h3", "h4", "h5", "h6", "head", "header", "hr", "html", "i", "iframe",
  "img", "input", "ins", "kbd", "keygen", "label", "legend", "li", "link",
  "main", "mark", "map", "menu", "menuitem", "meta", "meter", "nav",
  "noscript", "object", "ol", "optgroup", "option", "output", "p", "param",
  "pre", "progress", "q", "ruby", "rp", "rt", "s", "samp", "script", "section",
  "select", "small", "source", "span", "strong", "style", "sub", "summary",
  "sup", "table", "tbody", "td", "textarea", "tfoot", "th", "thead", "time",
  "title", "tr", "track", "u", "ul", "var", "video", "wbr"
]

# Set up all HTML5 tags as partials
for tag in Gunther.html5Tags
  do (tag) ->
    Gunther.addPartial tag, (args...) -> @element.apply this, [tag].concat args
