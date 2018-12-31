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
server
task

put!(server.in, "jj")

task

server.out

take!(server.out)


logr.Previous
take!(server.out)
take!(server.out)
