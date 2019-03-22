module EquationEditor
using WebSockets
import WebSockets.ServerWS
using Latexify
import WebSockets: with_logger,
                   Dates,
                   LogLevel,
                   Logging.Debug,
                   Logging.Info,
                   Logging.Warn,
                   Wslog

export latexify, serveEE
include(joinpath(dirname(pathof(WebSockets)), "..", "benchmark", "functions_open_browsers.jl"))
include("serve.jl")
end  #module
