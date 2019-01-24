

const ns = "http://www.w3.org/2000/svg"
const nsl = "http://www.w3.org/1999/xlink"
const nse = "http://www.w3.org/2001/xml-events"
const defattrs = {baseProfile:"basic", width:"297mm", height:"420mm",
              viewBox:"0 0 297 420", version:"1.2" }

function createElementNSattributes( tag, attributes) {
    let elem = document.createElementNS(ns, tag)
    for (let a in attributes){
        if (a=="href"){
            //elem.setAttributeNS(nsl, "xmlns:xlink", nsl)
            elem.setAttribute("xmlns:xlink", nsl);
        } else if(a == "ev") {
            elem.setAttribute("xmlns:ev", nse)
        } else {
            elem.setAttribute(a, attributes[a])
        }
    }
    return elem
    }

export function insertSvg(containelem, tag, attributes){
    let svg = createElementNSattributes( tag, attributes)
    containelem.appendChild(svg)
    return svg
    }