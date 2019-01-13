using Test
using EquationEditor
const EE = EquationEditor
#import Base.CoreLogging: LogLevel, @logmsg
#logr = Base.CoreLogging.current_logger()
#logr.previous_logger.min_level = Base.CoreLogging.LogLevel(-10000)
#@logmsg Base.CoreLogging.LogLevel(-10000) "Show debug logs"
const server, task = serveEE()
@test !isready(server.out)
@test !istaskdone(task)

#= For debugging
server
task
put!(server.in, "die!")
if isready(server.out)
    println(String(take!(server.out)))
end
if isready(server.out)
    println(String(take!(server.out)))
end
=#
