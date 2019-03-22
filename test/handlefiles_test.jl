using Test
using EquationEditor
const EE = EquationEditor
@test length(EquationEditor.MIMETYPES) == 985
reqstr = "svg\\Mickey%20mouse.svg/"
reqstr = reqstr |> EE._bck2fwdslash
reqstr = reqstr |> EE._unescapeuri
@test "hh%20%za" |> EE._unescapeuri == ""
reqstr = reqstr |> EE._nobadchars
reqstr = reqstr |> EE.lowercase
reqstr = reqstr |> EE._nojumpup
reqstr = reqstr |> EE._nokeywords
reqstr = reqstr |> EE._maybeindexhtml
reqstr = reqstr |> EE._doubleslash2slash
@test reqstr |> EE._startslash == "/svg/mickey mouse.svg/index.html"
@test reqstr |> EE._startslash == "/svg/mickey mouse.svg/index.html"
# Note: Query strings should be handled elsewhere. This file handler will just return a 404 file not found.
reqstr = "/fonts/fa.woff?ver=4.7.0;duck=bird&cat=feline"
@test  reqstr |> EE._noschemechars == "/fonts/fa.woff?ver4.7.0duckbirdcatfeline"
@test  reqstr |> EE._censoredrequest == "/fonts/fa.woffver4.7.0duckbirdcatfeline"
@test EE._censoredrequest("/svg/../others/") == "/svg/others/index.html"
@test EE._censoredrequest("../fonts/others/") == "/fonts/others/index.html"
@test EE._censoredrequest("/svg/Mickey%20%mouse.svg/") == "/index.html"
@test EE._censoredrequest("/html/touch-position/index.mjs") == "/html/touch-position/index.mjs"
@test EE._censoredrequest("mehekje.dot.no") == "/mehekje.dot.no"

show(EE._censoredrequest("/fonts/fa.woff?ver=4.7.0;duck=bird&cat=feline"))
show(EE._noschemechars("?A:;!"))
@test EE._censoredrequest("/svg/") == "/svg/index.html"




@test EE._longfilename("XX") == EE.FOLDERHOME * "XX"
@test EE._longfilename("/svg/Julia.svg") |> EE._pubfilename == "/svg/Julia.svg"
@test EE._longfilename("/fonts/fa.woff?ver=4.7.0") |> EE._pubfilename == "/fonts/fa.woff?ver=4.7.0"
@test EE._locfolder("/svg/special/Julia.svg") == "/svg/"
@test EE._locfolder("/stylesheet.css") == "/css/"
@test EE._locfolder("/stylesheet.woff") == "/html/"
@test EE._locfolder("/fonts/stylesheet.woff") == "/fonts/"
@test EE._locfolder("/jsmodule.mjs") == "/mjs/"
@test EE._locfolder("/gl-vec2/copy.mjs") == "/mjs/"
@test EE._locfolder("/html/touch-position/index.mjs") == "/mjs/"
@test EE._locfolder("/svg/index.html") == "/svg/"
@test EE._locfolder("/fonts/fa.woff?ver=4.7.0") == "/fonts/"

@test EE._topfolder_modreq("/Mickey.jpg") == ("/img/", "/img/mickey.jpg")
@test EE._topfolder_modreq("/img/Mickey.jpg") == ("/img/", "/img/mickey.jpg")
@test EE._topfolder_modreq("/html/touch-position/index.mjs") == ("/mjs/", "/mjs/touch-position/index.mjs")
@test EE._topfolder_modreq("/sub/touch-position/index.mjs") == ("/mjs/", "/mjs/sub/touch-position/index.mjs")
@test EE._topfolder_modreq("/sub/touch-position/index.mjs?ver=4.0.2") == ("/html/", "/html/sub/touch-position/index.mjsver4.0.2")
@test EE._topfolder_modreq("/sub/") == ("/html/", "/html/sub/index.html")
@test EE._topfolder_modreq("/html/index.html") == ("/html/", "/html/index.html")
@test EE._topfolder_modreq("/html/html/index.html") == ("/html/", "/html/html/index.html")
@test EE._topfolder_modreq("/svg/") == ("/svg/", "/svg/index.html")
@test EE._topfolder_modreq("/fonts/") == ("/fonts/", "/fonts/index.html")

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
response = EE.handle_file(req)
@test response.status == 200
response = EE.handle_file(EE.WebSockets.Request("get", "/favicon.ico"))
@test response.status == 200
