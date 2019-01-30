// Provides a roughly similar interface as in insertSvg.mjs
// The context is xhtml documents inside svg/foreignObject, html5.

export function insertHtmlElemFromText(parent, stringHtml){
    let template = parent.ownerDocument.createElement("template")
    template.innerHTML = stringHtml
    let ne = template.content
    let clone = document.importNode(ne, true);
    parent.appendChild(clone)
    return parent.lastChild
}