import std/[jsffi, strutils, sequtils]
import dom

var AWS {.importc, nodecl.}: JsObject
var console {.importc, nodecl.}: JsObject

type 
  Params {.exportc.} = object
    credentials: JsObject
    region: cstring
  Empty {.exportc.} = object
  StsGetCallerIdentityResp = ref object
    Account: cstring
    Arn: cstring
    UserId: cstring
  DescribeAlarmsReq {.exportc.} = object
    AlarmNames: seq[cstring]
  MetricAlarms = object
    ActionsEnabled: bool
    AlarmArn: cstring
    AlarmDescription: cstring
    AlarmName: cstring
    StateValue: cstring
  DescribeAlarmsResp = ref object
    CompositeAlarms: seq[JsObject]
    MetricAlarms: seq[MetricAlarms]
  AwsError = ref object
    message: cstring
    name: cstring
    code: cstring
    statusCode: int


proc try_creds(e: Event) =
  document.getElementById("output").innerHTML = ""
  document.getElementById("cwoutput").innerHTML = ""
  let 
    ak = document.getElementById("access_key").value
    sk = document.getElementById("secret_key").value
    alarmnames : seq[cstring] = ($document.getElementById("alarmname").value).split(", ").map(proc(x: string): cstring = cstring(x))
  
  let 
    awscreds = jsnew AWS.Credentials(ak, sk)
    p = Params(credentials: awscreds, region: "us-east-1")
    sts = jsnew AWS.STS(p)
    cw = jsnew AWS.CloudWatch(p)
    empty = Empty()
    cwconf = DescribeAlarmsReq(AlarmNames: alarmnames)

  sts.getCallerIdentity(empty, 
    proc(e: AwsError, d: StsGetCallerIdentityResp) =
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

  cw.describeAlarms(cwconf, proc(e: AwsError, d: DescribeAlarmsResp) =
    let outdiv = document.getElementById("cwoutput")
    if not isNil(e):
      let errorp = document.createElement("p")
      errorp.style.color = "red"
      errorp.innerHTML = "ERROR: " & e.message
      outdiv.appendChild(errorp)
    else:
      for a in d.MetricAlarms:
        let outp = document.createElement("p")
        if a.StateValue != "OK":
          outp.style.color = "red"
        outp.innerHTML = a.AlarmName & " status: " & a.StateValue
        outdiv.appendChild(outp)
  
  )
  
proc on_load(e: Event) =
  let sb = document.getElementById("submit_button")
  sb.addEventListener("click", try_creds)

window.onload = on_load