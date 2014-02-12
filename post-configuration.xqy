xquery version "1.0-ml";

import module namespace setup = "http://marklogic.com/ps/setup" at "lib-setup.xqy";

declare namespace sec = "http://marklogic.com/xdmp/security";
declare namespace xdmp="http://marklogic.com/xdmp";
declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace db="http://marklogic.com/xdmp/database";
declare namespace gr="http://marklogic.com/xdmp/group";
declare namespace err="http://marklogic.com/xdmp/error";
declare namespace ho="http://marklogic.com/xdmp/hosts";
declare namespace as="http://marklogic.com/xdmp/assignments";
declare namespace fs="http://marklogic.com/xdmp/status/forest";
declare namespace mt="http://marklogic.com/xdmp/mimetypes";
declare namespace pki="http://marklogic.com/xdmp/pki";

let $config := xdmp:get-request-body("xml")/*:configuration
let $set := xdmp:set-session-field("config", $config)
let $json := json:object()
let $databases-js := json:array()
let $database := 
    for $database in setup:get-databases-from-config($config)
    let $name := setup:get-database-name-from-database-config($database)
    let $js := json:object()
    let $_ := (
        map:put($js,"id",$name),
        map:put($js,"name",$name)
    )
    order by $name
    return  json:array-push($databases-js,$js)
let $forests-js := json:array()
let $forests := 
    for $forest in $config//*:assignments/*:assignment
    let $name := fn:string($forest/*:forest-name)
    let $js := json:object()
    let $_ := (
        map:put($js,"id",$name),
        map:put($js,"name",$name),
        map:put($js,"dataDir",fn:string($forest/as:data-directory))
    )
    order by $name
    return json:array-push($forests-js,$js)
let $servers-js := json:array()
let $servers := 
    for $s in $config//(*:http-server|*:xdbc-server)
    let $name := fn:string($s/(*:xdbc-server-name|*:http-server-name)[1])
    let $type := 
        typeswitch($s)
           case element(gr:http-server) return "http"
           case element(gr:xdbc-server) return "xdbc"
           case element(gr:odbc-server) return "odbc"
           default return ""
    let $js := json:object()
    let $_ := (
        map:put($js,"type",$type), 
        map:put($js,"id",$name),
        map:put($js,"name",$name),
        map:put($js,"port",fn:data($s/*:port))
    )
    return
       json:array-push($servers-js,$js)
let $roles-js := json:array()
let $roles := 
    for $r in $config//sec:role
    let $js := json:object()
    let $_ := (
        map:put($js,"id",fn:data($r/sec:role-name)),
        map:put($js,"name",fn:data($r/sec:role-name))
    )
    order by $r/sec:role-name
    return json:array-push($roles-js,$js)
let $users-js := json:array()
let $user := 
    for $u in $config//sec:user
    let $js := json:object()
    let $_ := (
        map:put($js,"id",fn:data($u/sec:user-name)),
        map:put($js,"name",fn:data($u/sec:description))
    )
    order by $u/sec:user-name
    return $js 
let $_ := for $u in $user return json:array-push($users-js,$u)
return (
    map:put($json,"databases",$databases-js),
    map:put($json,"forests",$forests-js),
    map:put($json,"servers",$servers-js),
    map:put($json,"roles",$roles-js),
    map:put($json,"users",$users-js),
    xdmp:set-response-content-type("application/json"),
    xdmp:to-json($json)
)
  

