module EquationEditor
export latexify, serveEE
using WebSockets
import WebSockets:  Logging.shouldlog,
                    Logging.ConsoleLogger
shouldlog(::ConsoleLogger, level, _module, group, id) = _module != WebSockets.HTTP.Servers
import WebSockets.Dates
using Latexify
using Revise
include("serve.jl")


end #module
