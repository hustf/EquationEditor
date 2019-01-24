using Test
using EquationEditor
const EE = EquationEditor
const server, task = serveEE()
EE.open_browser("chrome", url = "localhost:8000/interact.html")

# Non recursive
Revise.includet(joinpath(@__DIR__, "track_this.jl"))
# Recursive:
#Revise.track

logger = Revise.debug_logger(; min_level=-1000)
logger

Revise.FileModules
Revise.MethodSummary

logger

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
