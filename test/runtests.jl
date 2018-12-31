using EquationEditor

ex = :(x/(y+x)^2)
lst = latexify(ex)
Base.find_package("WebSockets")
using Test

@testset "handlefiles" begin
    include("handlefiles_test.jl")
end
@testset "serve" begin
    include("serve_test.jl")
end
