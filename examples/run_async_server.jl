using EquationEditor
const EE = EquationEditor
const logger =  EE.WebSocketLogger(stderr, Base.CoreLogging.Debug, right_justify = 10)
const server, task = serveEE(logger)
EE.open_browser("chrome", url = "localhost:8000/interact.html")
