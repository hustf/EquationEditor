function coroutine_pagecontrol(ws)
    @info ws
    while isopen(ws)
        data, success = readguarded(ws)
        if success
            @show String(data)
        end
    end
    @info "Closing ", ws
end
