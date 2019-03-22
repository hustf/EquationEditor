// We rely on scripting and styling to equate 1 mm to 1 user coordinate system unit.
// In effect, units scaling can be dropped in the svg context. 
// The effect should be that .

    // possible todo
    //import {toPX} from "/to-px/index.mjs"
    //var lineHeight = toPX('ex', element)


// TODO use the extracted scaling info when inserting foreignobject. 



import {insertFirstHtmlElemFromText} from "/insertxhtml.mjs"
import {fixedSizeForeignObject, extractSVGScale, fixScale} from "/fixed-size-foreignObject.mjs"
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

// The child is wrapped in a group with some exceptions
function _addChild(parent,  tag, attributes){
    let needGroup = _needNewGroup(parent, tag)
    // This lets the new element inherit style from its containing element,
    // which determines its bounding box.
    let ne = insertSvgElem(parent, tag, attributes)
    if (ne === null) throw "ouch";
    if (needGroup && Reflect.has(ne, "getBBox")) {
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
    if (["svg", "g", "a", "defs", "switch", "pattern", "foreignobject", "view"].includes(tag.toLowerCase())) return true
    return false
}

function* _idMaker() {
    let index = 0
    while (index < index+1)
      yield index++
  }
function _needNewGroup(parent, tag){
   if (["defs",  "symbol", "use", "g"].includes(tag.toLowerCase())) return false
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



export function insertA3(parent){
	// We rely on 'section' height 440 mm for scaling.
	// The effect should be that 1 svg user unit = 1 mm.
	let section = insertFirstHtmlElemFromText(parent, `<section class="panzoom svgcontainer", display = "block", height="440mm", width = "317mm"></section>`)
	// Class a3 styling in css includes a margin of 10 + 10 mm inside the section.
	let svga3 = insertSvgElem(section, "svg",  {baseProfile:"basic",
		version:"2.0", viewBox:"0, 0, 297, 420", width:"297mm", height:"420mm",
		class:"a3"})
	//	Font size can't reliably be given in css.
	svga3.style.fontSize = 3.52777 // This is 10 pt in paper fonts. User coordinate lengths can't be reliably given through css.
	svga3.setAttribute("stroke-width", 0.1763888)
	def_cm_grid(svga3)
	// In order to prevent inheritance of margin 10 mm to any contents of the document,
	// we make everything descend from a group with zero margin set in css.
	let paper = svga3.addChild({ tag:"g", class:"paper"})
	// Adding a nearly invisible cm / mm grid to the paper. Could go under 'decorations'.
	paper.addChild({ tag:"rect", class:"paper", fill:"url(#cmgrid)"})
	// Add property scaleRatio to this node. Used for inserting ForeignObjects.
	extractSVGScale(window, paper)
	return paper
}

function def_cm_grid(svgport){
	let defs = svgport.addChild({tag:"defs"})
	function def_mm_grid(){
		let mmGrid = defs.addChild({tag:"pattern", id:"mmgrid", width:"1", height:"1", patternUnits:"userSpaceOnUse"})
		mmGrid.addChild({tag:"rect", width:1, height:1, fill:"var(--co6)", stroke:"var(--co4)"}).setAttribute("stroke-width", "0.03")
	}
	def_mm_grid()
	let cmGrid = defs.addChild({tag:"pattern", id:"cmgrid", width:"10", height:"10", patternUnits:"userSpaceOnUse"})
    cmGrid.addChild({tag:"rect", width:10, height:10, fill:"url(#mmgrid)", stroke:"var(--co5)"}).setAttribute("stroke-width", "0.1")
}