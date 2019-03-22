include("h_file.jl")
const EEPORT = 8000

function http_gatekeeper(req)
    if req.method == "GET"
        handle_file(req)
        # Add a Pragma header (should not be stripped by proxies)?
        # Or better, inject in document?
    else
        Response(501, "Unimplemented method on this server: $(req.method)")
    end
end

WebSockets.addsubproto("relay_frontend") # For testing the template file
WebSockets.addsubproto("pagecontrol") # Use one sub protocol per object from Revise?
function ws_gatekeeper(req, ws)
    @info "ws_gatekeeper", req
    # Check against value sent by this server....
    if WebSockets.subprotocol(req) == "pagecontrol"
        coroutine_pagecontrol(ws)
    end
end

function serveEE(logger= WebSocketLogger())
    server = ServerWS(http_gatekeeper, ws_gatekeeper)
    task = @async   with_logger(logger) do
        WebSockets.serve(server, port = EEPORT)
    end
    @info "http://localhost:$EEPORT"
    return server, task
end
