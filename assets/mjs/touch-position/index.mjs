//var offset = require('mouse-event-offset');
import {mouseEventOffset as offset} from "/mouse-event-offset/index.mjs";
//var EventEmitter = require('events').EventEmitter;
import {EventEmitter} from "/events/events.mjs";
function attach (opt) {
  opt = opt || {};
  var element = opt.element || window;

  var emitter = new EventEmitter();

  var position = opt.position || [0, 0];
  if (opt.touchstart !== false) {
    element.addEventListener('mousedown', update, false);
    element.addEventListener('touchstart', updateTouch, false);
  }

  element.addEventListener('mousemove', update, false);
  element.addEventListener('touchmove', updateTouch, false);

  emitter.position = position;
  emitter.dispose = dispose;
  return emitter;

  function updateTouch (ev) {
    var touch = ev.targetTouches[0];
    update(touch);
  }

  function update (ev) {
    offset(ev, element, position);
    emitter.emit('move', ev);
  }

  function dispose () {
    element.removeEventListener('mousemove', update, false);
    element.removeEventListener('mousedown', update, false);
    element.removeEventListener('touchmove', updateTouch, false);
    element.removeEventListener('touchstart', updateTouch, false);
  }
}


function position(opt) {
  return attach(opt).position;
};

position.emitter = function (opt) {
  return attach(opt);
};

export {position};


//export module.exports = function (opt) {
//export function position(opt) {
//  return attach(opt).position;
//};

//module.exports.emitter = function (opt) {
//export function (opt) {
//    return attach(opt);
//};
