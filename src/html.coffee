# HTML information class
class Gunther.HTML

    # All HTML5 elements :)
    # For each element in this set a function will be created on Gunther's prototype
    @elements = ["a", "abbr", "address", "article", "aside", "audio", "b",
        "bdi", "bdo", "blockquote", "body", "button", "canvas", "caption", "cite",
        "code", "colgroup", "datalist", "dd", "del", "details", "dfn", "div", "dl",
        "dt", "em", "fieldset", "figcaption", "figure", "footer", "form", "h1",
        "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup", "html", "i",
        "iframe", "ins", "kbd", "label", "legend", "li", "map", "mark", "menu",
        "meter", "nav", "noscript", "object", "ol", "optgroup", "option", "output",
        "p", "pre", "progress", "q", "rp", "rt", "ruby", "s", "samp", "script",
        "section", "select", "small", "span", "strong", "style", "sub", "summary",
        "sup", "table", "tbody", "td", "textarea", "tfoot", "th", "thead", "time",
        "title", "tr", "u", "ul", "video", "area", "base", "br", "col", "command",
        "embed", "hr", "img", "input", "keygen", "link", "meta", "param", "source",
        "track", "wbr", "applet", "acronym", "bgsound", "dir", "frameset",
        "noframes", "isindex", "listing", "nextid", "noembed", "plaintext", "rb",
        "strike", "xmp", "big", "blink", "center", "font", "marquee", "multicol",
        "nobr", "spacer", "tt", "basefont", "frame"]

    # List of default HTML Events
    # should be easy enough to extend with custom events
    @eventNames: ['load', 'unload', 'blur', 'change', 'focus', 'reset',
        'select', 'submit', 'abort', 'keydown', 'keyup', 'keypress', 'click',
        'dblclick', 'mousedown', 'mouseout', 'mouseover', 'mouseup']
