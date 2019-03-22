#using Test
using EquationEditor
#import EquationEditor: LogLevel, Debug, Info, Wslog, with_logger
#import EquationEditor.WebSocketLogger
const EE = EquationEditor
#with_logger(WebSocketLogger(stderr, Debug)) do
#    @info "Info"
#    @debug "Debug"
#end
const server, task = serveEE()
EE.open_browser("chrome", url = "localhost:8000/interact.html")



# Non recursive
Revise.includet(joinpath(@__DIR__, "track_this.jl"))
# Recursive:
#Revise.track

codelogger = Revise.debug_logger(; min_level = Base.CoreLogging.Debug)

Revise.FileModules
Revise.MethodSummary


lastlog = logger.logs[end]

fieldnames(typeof(lastlog))
println(lastlog.file)

lastlog.file

lastkwargs = Dict(lastlog.kwargs)

lastmod, lastrelocatableexpr = get(lastkwargs, :deltainfo, "")

# Create a page for lastmod if OK, store it as a file, serve it, include metadata for changeable expression positions, also update over websocket.


Revise.actions(logger, line = true)


# Add these to watched files, make a proprietary file format similar to MathML, MathCad or Mathjax?
Revise.watched_files
