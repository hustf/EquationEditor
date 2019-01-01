//module.exports = defaultProperty

export function defaultProperty (get, set) {
  return {
    configurable: true,
    enumerable: true,
    get: get,
    set: set
  }
}
