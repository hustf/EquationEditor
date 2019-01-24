import { scrollbarModel } from "../display/scrollbars.mjs"
import { wheelEventPixels } from "../display/scroll_events.mjs"
import { keyMap, keyName, isModifierKey, lookupKey, normalizeKeyMap } from "../input/keymap.mjs"
import { keyNames } from "../input/keynames.mjs"
import { Line } from "../line/line_data.mjs"
import { cmp, Pos } from "../line/pos.mjs"
import { changeEnd } from "../model/change_measurement.mjs"
import Doc from "../model/Doc.mjs"
import { LineWidget } from "../model/line_widget.mjs"
import { SharedTextMarker, TextMarker } from "../model/mark_text.mjs"
import { copyState, extendMode, getMode, innerMode, mimeModes, modeExtensions, modes, resolveMode, startState } from "../modes.mjs"
import { addClass, contains, rmClass } from "../util/dom.mjs"
import { e_preventDefault, e_stop, e_stopPropagation, off, on, signal } from "../util/event.mjs"
import { splitLinesAuto } from "../util/feature_detection.mjs"
import { countColumn, findColumn, isWordCharBasic, Pass } from "../util/misc.mjs"
import StringStream from "../util/StringStream.mjs"

import { commands } from "./commands.mjs"

export function addLegacyProps(CodeMirror) {
  CodeMirror.off = off
  CodeMirror.on = on
  CodeMirror.wheelEventPixels = wheelEventPixels
  CodeMirror.Doc = Doc
  CodeMirror.splitLines = splitLinesAuto
  CodeMirror.countColumn = countColumn
  CodeMirror.findColumn = findColumn
  CodeMirror.isWordChar = isWordCharBasic
  CodeMirror.Pass = Pass
  CodeMirror.signal = signal
  CodeMirror.Line = Line
  CodeMirror.changeEnd = changeEnd
  CodeMirror.scrollbarModel = scrollbarModel
  CodeMirror.Pos = Pos
  CodeMirror.cmpPos = cmp
  CodeMirror.modes = modes
  CodeMirror.mimeModes = mimeModes
  CodeMirror.resolveMode = resolveMode
  CodeMirror.getMode = getMode
  CodeMirror.modeExtensions = modeExtensions
  CodeMirror.extendMode = extendMode
  CodeMirror.copyState = copyState
  CodeMirror.startState = startState
  CodeMirror.innerMode = innerMode
  CodeMirror.commands = commands
  CodeMirror.keyMap = keyMap
  CodeMirror.keyName = keyName
  CodeMirror.isModifierKey = isModifierKey
  CodeMirror.lookupKey = lookupKey
  CodeMirror.normalizeKeyMap = normalizeKeyMap
  CodeMirror.StringStream = StringStream
  CodeMirror.SharedTextMarker = SharedTextMarker
  CodeMirror.TextMarker = TextMarker
  CodeMirror.LineWidget = LineWidget
  CodeMirror.e_preventDefault = e_preventDefault
  CodeMirror.e_stopPropagation = e_stopPropagation
  CodeMirror.e_stop = e_stop
  CodeMirror.addClass = addClass
  CodeMirror.contains = contains
  CodeMirror.rmClass = rmClass
  CodeMirror.keyNames = keyNames
}
