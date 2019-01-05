#=
Converts requests for files in certain folders and subfolders into responses.
May pick the right folder based on request extension.
Generates index.html on request.
=#
# defines MIMETYPES
include("mimetypes.jl")
"Root of LOCFLDRS"
const FOLDERHOME = replace(joinpath(@__DIR__, "..") |> realpath, "\\" => "/")
const RGX_FOLDERHOME = Regex("^"* FOLDERHOME)

"Contains the local path to folders to expose. Subfolders will also be exposed."
const LOCFLDRS = [ "/js/", "/html/", "/svg/", "/img/", "/mjs/", "/css/"]
const IMGEXT = r"jpg|jpeg|png|gif|tiff|tif"
const TINDEX ="""<!DOCTYPE html><html><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta http-equiv="x-ua-compatible" content="ie=edge">
<title>Index.html</title></head><body></body></html>"""

"""
Index in String / html format to 1st level in the given folder.
Note, 'Mustache.jl' does these things more elegantly.
"""
function _htmlindex(di::String)
    pubdi = _pubfilename(di)
    if !isdir(di)
        @info "Invalid path:"* di
        error(Base.ArgumentError("Invalid path"))
    end
    shnams =  readdir(di)
    if pubdi *"/" ∈ LOCFLDRS
        # Include links to the other LOCFLDRS."
        foreach(LOCFLDRS) do fol
                              if fol != pubdi *"/"
                                  push!(shnams, ".." * fol[1:end-1])
                              end
                        end
    end
    longnams = di * "/" .* shnams
    timstamps = map(mtime, longnams)
    dtgs = map(timstamps) do ts
        Dates.format(Dates.unix2datetime(ts), Dates.RFC1123Format)
    end
    pubnams = pubdi * "/" .* shnams
    pubnams = map(shnams, longnams) do sn, lna
        isdir(lna) ? pubdi * "/" * sn * "/" : pubdi * "/" * sn
    end
    shownams = map(shnams, longnams) do sn, lna
                            isdir(lna) ? "/" * sn * "/" : sn
                        end
    matr = Array{Any,2}(undef, length(pubnams), 4)
    matr[:, 1] = timstamps
    matr[:, 2] = shownams
    matr[:, 3] = pubnams
    matr[:, 4] = dtgs
    smatr = sortslices(matr, dims =1, rev = true)
    # HTML Table rows with folders /../ in di
    tablcont = join(mapslices(smatr, dims = 2) do rw
        shownam, pubnam, dtg = rw[2], rw[3], rw[4]
        if shownam[1:4] == "/../"
            """<tr><td><a href="$pubnam">$shownam</a></td><td>$dtg</td></tr>"""
        else
            ""
        end
    end)
    # HTML Table rows with subordinate folders in di
    tablcont *= join(mapslices(smatr, dims = 2) do rw
                        shownam, pubnam, dtg = rw[2], rw[3], rw[4]
                        if shownam[1] == '/' && shownam[1:4] != "/../"
                            """<tr><td><a href="$pubnam">$shownam</a></td><td>$dtg</td></tr>"""
                        else
                            ""
                        end
                    end
                )
    # HTML table rows with files in di
    tablcont *= join(mapslices(smatr, dims = 2) do rw
                        shownam, pubnam, dtg = rw[2], rw[3], rw[4]
                        if shownam[1] != '/'
                            """<tr><td><a href="$pubnam">$shownam</a></td><td>$dtg</td></tr>"""
                        else
                            ""
                        end
                    end
                )
    bodyc = "<body><h1>Index $pubdi</h1><table><tbody>" * tablcont * "</tbody></table></body>"
    replace(TINDEX, "<body></body>" => bodyc)
end

_bck2fwdslash(pth) = replace(pth, "\\" => "/")
_doubleslash2slash(pth) = replace(pth, "//" => "/")
_nobadchars(pth) = replace(pth, r"^\s*(?:#|$<>~!)" => "")
_nojumpup(pth) = replace(pth,r"\.{2,}" => "")
_nokeywords(pth) = replace(pth, r"prn"i=>"")
_maybeindexhtml(pth) = pth =="" || pth[end]=='/' ? pth * "index.html" : pth
_startslash(pth) = startswith(pth, "/") ? pth : "/" * pth
"""
Converts e.g. %20 to space
From URIParser.jl, added: misformed -> ""
"""
function _unescapeuri(str)
    r = UInt8[]
    l = length(str)
    i = 1
    while i <= l
        c = str[i]
        i += 1
        if c == '%'
            try
                c = parse(UInt8, str[i:i+1], base=16)
                i += 2
            catch
                return ""
            end
        end
        push!(r, c)
    end
   return String(r)
end
"
Makes an attempt at safeguarding against malicious requests before file access.
Also adds 'index.html' if request does not specify a possible file.
"
_censoredrequest(pubreq::String) = pubreq |>  _bck2fwdslash |> _unescapeuri |> _nobadchars |>
                                   lowercase |> _nojumpup |> _nokeywords |>
                                    _maybeindexhtml |> _doubleslash2slash |> _startslash

"""
Returns _locfolder ∈ LOCFLDRS from a requested resource.
If /folder/ is missing, but file extension corresponds to one
of LOCFLDRS,
Defaults to /html/
# Examples
```julia-repl
_locfolder("/cat.svg") -> "/svg/cat.svg"
_locfolder("/cat.unknown") -> "/html/cat.unknown"
_locfolder("/secret/file.txt") -> "/html/"
```
Assumes input is already cleaned of maliciuos requests like "/svg/../../secret/big.txt"
and is lowercase
"""
function _locfolder(creq::String)
    fofirst ="/" * get(split(creq, "/"), 2, "") *"/"
    flast = split(creq, "/")[end]
    fileextension =  splitext(flast)[end][2:end]
    fofilextension = "/" * replace(fileextension, IMGEXT => "img") * "/"
    if flast != "index.html" && fofilextension ∈ LOCFLDRS
        return fofilextension
    end
    if fofirst ∈ LOCFLDRS
        return fofirst
    end
    return "/html/"
end

"
public request - >  (top folder, modified request)
Picks a path ∈ LOCFLDRS, based on
    1) file extension (/img/fig.svg -> /svg/fig.svg)
    2) default  (/X.abc -> /html/X.abc)
"
function _topfolder_modreq(pubreq::String)
    censoredreq = pubreq |> _censoredrequest
    topfolder = _locfolder(censoredreq)
    if startswith(censoredreq, topfolder)
        # Make checks against /html/html/doc.html?
        return topfolder, censoredreq
    end
    # top folder was not taken directly from the request.
    if topfolder != "/html/" && occursin("/html/", censoredreq)
        #= Document link:           "./pic.jpg"
        -> request:                 "/html/pic.jpg"
        -> topfolder, censoredreq:  "/img/", "/html/pic.jpg"
        -> topfolder, modreq:       "/img/", "/img/pic.jpg"
        =#
        return topfolder, replace(censoredreq, "/html/" => topfolder)
    end
    #= Document link:           "./holiday/pic.jpg"
    -> request:                 "/html/holidaypic.jpg"
    -> topfolder, censoredreq:  "/img/", "/html/holidaypic.jpg"
    -> topfolder, modreq:       "/img/", "/img/pic.jpg"
    =#
    return topfolder, topfolder * censoredreq |> _doubleslash2slash
end

"Full path to requested file"
_longfilename(modreq::String) = occursin(RGX_FOLDERHOME, modreq) ? modreq : FOLDERHOME * modreq

"Visible name, for index.html"
_pubfilename(longfnam::String) = replace(longfnam, RGX_FOLDERHOME => "")

"Returns (status{Int}, body{Vector{UInt8} , mime{String}, lastmodified{String}:<day-name>, <day> <month> <year> <hour>:<minute>:<second> GMT
Used for building HTTP.Response"
function _rawresponse(pubreq::String)
    topfolder, modreq = pubreq |>  _topfolder_modreq
    longreq = modreq |> _longfilename
    @debug("Public request:\t" * pubreq *
        "\n\tModified request:\t" * modreq *
        "\n\tTop folder:\t" * topfolder *
        "\n\tLong request:\t" * longreq)
    if occursin(r"index.htm"i, splitdir(modreq)[2]) && isdir(splitdir(longreq)[1])
        status = 200
        body = _htmlindex(splitdir(longreq)[1])
        tstamp =  time()
        (_, ext) = splitext(modreq)
        mime = get(MIMETYPES, ext[2:end], "application/octet-stream")
    elseif isfile(longreq)
        status = 200
        body = read(longreq)
        tstamp = mtime(longreq)
        (_, ext) = splitext(modreq)
        mime = get(MIMETYPES, ext[2:end], "application/octet-stream")
    else
        status = 404
        body = Vector{UInt8}("Not Found (404):  $modreq could not be found.")
        mime = "text/html"
        tstamp = time()
        @info(modreq * " could not be found. Looked in " * topfolder)
    end
    return status, body, mime, Dates.format(Dates.unix2datetime(tstamp), Dates.RFC1123Format) * " GMT"
end


"To be called by handler. -> Response is the corresponding file with defined mime type info."
function _handle_file(pubreq::WebSockets.Request, resp::WebSockets.Response)
    status, body, mime, tstamp = _rawresponse(pubreq.target)
    if typeof(body) == String
        resp.body = codeunits(body)
    else
        resp.body = body
    end
    WebSockets.setheader(resp, WebSockets.Header("Content-Type", mime))
    WebSockets.setheader(resp, WebSockets.Header("Content-Length",  string(length(body))))
    WebSockets.setheader(resp, WebSockets.Header("Last-Modified", tstamp))
    resp.status = status
    if status != 200
        @info "Failure to handle $(pubreq.target)"
    end
    resp
end
handle_file(pubreq::WebSockets.Request) = _handle_file(pubreq, WebSockets.Response())
nothing
