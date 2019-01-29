// We rely on outside scripting and styling to equate 1 mm to 1 user coordinate system unit.
// In effect, units scaling can be dropped in this context. 
// The effect should be that .
    //import {toPX} from "/to-px/index.mjs"
    //var lineHeight = toPX('ex', element)


const ns = "http://www.w3.org/2000/svg"
const nsl = "http://www.w3.org/1999/xlink"
const nse = "http://www.w3.org/2001/xml-events"
// defaults used when calling elem.addChild without arguments.
const tagDefault = "rect"
const xDefault = "0"
const yDefault = "0"
const heightDefault = "25"
const widthDefault = "25"
const colorDefault = "blueviolet"
const idGenerator = _idMaker()

export function insertSvgElem(parent, tag, attributes){
    let unappended = _createElementNSattributes(tag, attributes)
    if (_shouldHaveAddChild(tag, attributes)){
        unappended.addChild = function({tag = tagDefault,  ...otherparams} = 
                                        {tag:tagDefault, x:xDefault, y:yDefault, height:heightDefault, width:widthDefault, fill:colorDefault}) {
            // having supplied defaults, we can group them with other named parameters.
            return _addChild(unappended, tag, { ...otherparams})
        }
    }
    // consider addSibling, just refer parent instead of unappended.
    parent.appendChild(unappended) 
    return unappended // unappended is now appended
}

// If the parent is of class "paper", wrap the new element in a group.
function _addChild(parent,  tag, attributes){
    let needGroup = _needNewGroup(parent, tag)
    // This lets the new element inherit style from its containing element,
    // which determines its bounding box.
    let ne = insertSvgElem(parent, tag, attributes)
    if (needGroup){
        let bbox = ne.getBBox()
        ne.remove() // unlink ne from parent.
        let [ne_attributes, g_attributes, g_x, g_y] = _attributesForGroup(tag, attributes, bbox)
        let g =  _createElementNSattributes("g", g_attributes)
        ne = insertSvgElem(parent, tag, ne_attributes)
        g.appendChild(ne)
        parent.appendChild(g)
        g.setAttribute('transform', 'translate(0,0)')
        g.transform.baseVal[0].matrix.e = g_x
        g.transform.baseVal[0].matrix.f = g_y
    }
    return ne
} 




// make an element. Includes namespace when necessary (maybe not in svg 2.0).
function _createElementNSattributes(tag, attributes) {
    let elem = document.createElementNS(ns, tag)
    for (let a in attributes){
        if (a == "ev") {
            // check if setAttributeNS: https://dev.w3.org/SVG/profiles/2.0/publish/events.html
            elem.setAttribute("xmlns:ev", value)
        } else {
            if (a=="textContent"){
                elem.innerHTML = attributes[a]
            } else {
                elem.setAttribute(a, attributes[a])
            }
        }
    }
    return elem
}


function _shouldHaveAddChild(tag, attributes){
    if (["svg", "g", "a", "defs", "switch", "pattern"].includes(tag)) return true
    return false
}

function* _idMaker() {
    let index = 0
    while (index < index+1)
      yield index++
  }
function _needNewGroup(parent, tag){
   if (["defs",  "symbol", "use", "g"].includes(tag)) return false
   if (["defs", "symbol", "use", "pattern"].includes(parent.tagName)) return false
   if (parent.hasOwnProperty("class")) {
       let cl = attributes.class.toLowerCase().split(" ")
       if (cl.includes("paper")) return true
   }
   if (parent.tagname =="g") return false
   return true
}

// We want to wrap elements in groups.
// Some attributes needs renaming and/ or adaption.
// If no 'id' is included in attributes, make one up.
function _attributesForGroup(tag, attributes, bbox){
    let g_attributes = {width:bbox.width, height:bbox.height}
    let g_x = 0
    let g_y = 0
    if (attributes.hasOwnProperty("x")) {
        if (bbox.x != 0 ){
            g_x = bbox.x
            attributes.x -= bbox.x
            if (attributes.x == 0) delete(attributes.x)
        }
    } else if (attributes.hasOwnProperty("cx")){
        if (bbox.x != 0 ){
            g_x = bbox.x
            attributes.cx -= bbox.x
            if (attributes.cx == 0) delete(attributes.x)
        }
    }
    if (attributes.hasOwnProperty("y")) {
        if (bbox.y != 0 ){
            g_y = bbox.y
            attributes.y -= bbox.y
            if (attributes.y == 0) delete(attributes.y)
        }
    } else if (attributes.hasOwnProperty("cy")){
        if (bbox.y != 0 ){
            g_y = bbox.y
            attributes.cy -= bbox.y
            if (attributes.cy == 0) delete(attributes.y)
        }
    }
    // add id to g_attributes if....
    return [attributes, g_attributes, g_x, g_y]
}
