using Test
using EquationEditor
const EE = EquationEditor
@test length(EquationEditor.MIMETYPES) == 984
# todo try with some more malicious uris...
reqstr = "/svg\\Mickey%20mouse.svg/"
reqstr = reqstr |> EE._bck2fwdslash
reqstr = reqstr |> EE._unescapeuri
@test "hh%20%za" |> EE._unescapeuri == ""
reqstr = reqstr |> EE._nobadchars
reqstr = reqstr |> EE.lowercase
reqstr = reqstr |> EE._nojumpup
reqstr = reqstr |> EE._nokeywords
reqstr = reqstr |> EE._maybeindexhtml
reqstr = reqstr |> EE._doubleslash2slash
@test EE._censoredrequest("/svg/../others/") == "/svg/others/index.html"
EE._censoredrequest("/svg/Mickey%20%mouse.svg/") == "index.html"

@test EE._longfilename("XX") == EE.FOLDERHOME * "XX"
@test EE._longfilename("/svg/Julia.svg") |> EE._pubfilename == "/svg/Julia.svg"
@test EE._upmostfolder("/svg/special/Julia.svg") == "/svg/"
@test EE._upmostfolder("svg/special/Julia.svg") == "/html/"
@test EE._topfolder_modreq("/Mickey.jpg") == ("/img/", "/img/mickey.jpg")
@test EE._topfolder_modreq("/img/Mickey.jpg") == ("/img/", "/img/mickey.jpg")

cd("..")
pubstr = "/pwd/"
topfolder, modreq = pubstr |>  EE._topfolder_modreq
@test modreq == "/html/pwd/index.html"

pubstr = "/html/favicon.ico"
tf = EE.FOLDERHOME * pubstr
topfolder, modreq = pubstr |>  EE._topfolder_modreq
@test tf == EE._longfilename(modreq)
@test EE._pubfilename(tf) == pubstr


status, body, mime, tstamp = EE._rawresponse(pubstr)
skeleton = EE.WebSockets.Response()
skeleton.body = body
EE.WebSockets.setheader(skeleton, EE.WebSockets.Header("Content-Type", mime))
EE.WebSockets.setheader(skeleton, EE.WebSockets.Header("Content-Length",  string(length(body))))
EE.WebSockets.setheader(skeleton, EE.WebSockets.Header("Last-Modified", tstamp))
skeleton.status = status


pubindex = "/html/index.html"
@test EE._topfolder_modreq("") == ("/html/", pubindex)
@test EE._topfolder_modreq("/") == ("/html/", pubindex)
longindex = splitdir(EE.FOLDERHOME * pubindex)[1]
@test EE._pubfilename(longindex) == "/html"

@test typeof(EE._htmlindex(longindex)) == String

skeleton = EE.WebSockets.Response()
req = EE.WebSockets.Request("get", "/")
response = EE._handle_file(req, skeleton)
response = EE.handle_file(EE.WebSockets.Request("get", "/"))


req = EE.WebSockets.Request("get", "/favicon.ico")
req = EE.WebSockets.Request("get", "/favicon.ico")

response = EE.handle_file(req)
@test response.status == 200

response = EE.handle_file(EE.WebSockets.Request("get", "/favicon.ico"))
@test response.status == 200
