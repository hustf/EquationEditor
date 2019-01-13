import {panZoom as panzoom} from "/pan-zoom/index.mjs";
console.log("We are ready here");

// the zoomselector points the object we want to zoom and pan.
// there has been issues with event propagation switching. The fix
// was to put the image inside an object container. This is
// good practice when switching between zooming and working on
// subelements of and svg.
const zoomselector = ".panzoom";
const panzoomelement = document.querySelector(zoomselector)

	// constant
const bb = panzoomelement.getBoundingClientRect()
const wx = bb.width
const hy = bb.height
const xmin =	bb.x
const ymin =	bb.y
const xmax =	bb.width
const ymax = bb.height
let umin =	xmin
let vmin =	ymin
let umax =	xmax
let vmax = ymax
const maxscale = 4
const minscale = .5

// the transform matrix represented by 0-0, 1-0, 0-1, 1-1, 2-0, 2-1

let ctm = [1,0,0,0,0,0]

const do_pan_zoom = function(e){
	// when cursor drag up, e.dy is negative, typical e.dy = -1
	// when cursor drag right, e.dx is positive, typical e.dx = 1
	let wu = umax - umin
	let hv = vmax - vmin
	let s = wu / wx
	// rx, ry ∈ [0,1]
	// Consider using the container as a reference instead.

	let rx = (e.x - xmin ) / wx
	let ry = (e.y - ymin ) / hy
	let ru = (xmin  + e.x - umin) / wu
	let rv = (ymin + e.y - vmin ) / hv

  // zoom
  if (e.dz) {
			// when mouse wheel moves forward (Windows style zoom in),
			// or pinches with finger distance increasing,
			// e.dz is negative, typical -33.33 to -1733 depending on w.
			let dzoomh = clamp(-e.dz, -hy *.75, hy *.75) / hy
			let dzoomv = clamp(-e.dz, -wx *.75, wx *.75) / wx
			let dzoom = (dzoomh < 0) ? Math.min(dzoomh, dzoomv) : Math.max(dzoomh, dzoomv)
			// dzoom is positive when zooming in
			s += dzoom
			s = clamp(s, minscale, maxscale)
			wu = s * wx
			hv = s * hy
			umin = xmin  + e.x  - ru * wu
			vmin = ymin + e.y - rv * hv
			umax =  umin + wu
			vmax =  vmin + hv
	  }
		// pan
		umin += e.dx
		umax += e.dx
		vmin += e.dy
		vmax += e.dy
		// Even though coordinates origo is top-left,
		// the css transform matrix acts on a centered coordinate system.
		// So move rx, ry to center before scaling, afterwards move back.

		// This is just for scaling
		let tx = wx * (0.5 - rx)
		let ty = hy * (0.5 - ry)
		let tx2 = -wx * (0.5 - rx)
		let ty2 = -hy * (0.5 - ry)
    // This is just for panning
    tx2+= 0.5 * (umin + umax) - wx /2
		ty2+= 0.5 * (vmin + vmax) - hy /2

		let ctm = [s, 0,
							0, s,
							tx * s + tx2, ty * s + ty2]
		// the style object dictionary wants this as a string
		e.target.style["transform"] = "matrix(" + ctm.join(',') + ")"
}

let clamp = function (val, min, max) {
	(Math.min(Math.max(val, min), max) != val) && console.log("Clamping")
  return Math.min(Math.max(val, min), max)
}

let ff = panzoom(panzoomelement, do_pan_zoom)
