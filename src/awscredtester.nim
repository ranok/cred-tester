import std/jsffi
import dom

var AWS {.importc, nodecl.}: JsObject
var console {.importc, nodecl.}: JsObject

type 
  Credentials {.exportc.} = object
    credentials: JsObject
  Empty {.exportc.} = object
  StsGetCallerIdentityResp = ref object
    Account: cstring
    Arn: cstring
    UserId: cstring
  AwsStsError = ref object
    message: cstring
    name: cstring
    code: cstring
    statusCode: int


proc try_creds(e: Event) =
  document.getElementById("output").innerHTML = ""
  let 
    ak = document.getElementById("access_key").value
    sk = document.getElementById("secret_key").value
  
  let 
    awscreds = jsnew AWS.Credentials(ak, sk)
    p = Credentials(credentials: awscreds)
    sts = jsnew AWS.STS(p)
    empty = Empty()

  sts.getCallerIdentity(empty, 
    proc(e: AwsStsError, d: StsGetCallerIdentityResp) =
      let parentdiv = document.getElementById("output")
      if not isNil(e):
        let errorp = document.createElement("p")
        errorp.style.color = "red"
        errorp.innerHTML = "ERROR: " & e.message
        parentdiv.appendChild(errorp)
      else:
        let 
          arnp = document.createElement("p")
          useridp = document.createElement("p")
          accountp = document.createElement("p")
        arnp.innerHTML = "ARN: " & d.Arn
        useridp.innerHTML = "User ID: " & d.UserId
        accountp.innerHTML = "Account number: " & d.Account
        parentdiv.appendChild(accountp)
        parentdiv.appendChild(useridp)
        parentdiv.appendChild(arnp)
  )
  
  console.log(awscreds)

proc on_load(e: Event) =
  let sb = document.getElementById("submit_button")
  sb.addEventListener("click", try_creds)

window.onload = on_load