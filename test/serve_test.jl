using Test
using EquationEditor
const EE = EquationEditor
const server, task = serveEE()
@test !isready(server.out)
@test !istaskdone(task)
close(server)
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
