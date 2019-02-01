// Provides a roughly similar interface as in insertSvg.mjs
// The context is xhtml documents inside svg/foreignObject, html5.

// according to examples, we should enclose html in foreignObject like this:
// <body xmlns="http://www.w3.org/1999/xhtml"></body>
// but it does not seem to be necessary (in chrome)

export function appendHtmlElemFromText(parent, stringHtml){
    let clone = makeElement(parent, stringHtml)
    parent.appendChild(clone)
    return parent.lastChild
}

export function insertFirstHtmlElemFromText(parent, stringHtml){
    let clone = makeElement(parent, stringHtml)
    parent.insertBefore(clone, parent.firstChild)
    return parent.firstChild
}

function makeElement(parent, stringHtml){
    let template = parent.ownerDocument.createElement("template")
    template.innerHTML = stringHtml
    let ne = template.content
    return document.importNode(ne, true)
}