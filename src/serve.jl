include("h_file.jl")
const PORT = 8000

WebSockets.addsubproto("relay_frontend") # For testing the template file
WebSockets.addsubproto("pagecontrol") # Use one sub protocol per object from Revise?
function ws_gatekeeper(req, ws)
    @info "ws_gatekeeper", req
    if WebSockets.subprotocol(req) == "pagecontrol"
        coroutine_pagecontrol(ws)
    end
end
function serveEE()
    server = WebSockets.ServerWS(handle_file, ws_gatekeeper)
    task = @async WebSockets.serve(server, port = PORT)
    @info "http://localhost:$PORT"
    return server, task
end
