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

let $config :=  xdmp:get-session-field("config")
let $json := json:object()
let $database := 
    for $database in setup:get-databases-from-config($config)
    let $name := setup:get-database-name-from-database-config($database)
    let $js := json:object()
    let $_ := (
        map:put($js,"id",$name),
        map:put($js,"name",$name)
    )
    order by $name
    return  $js
let $forests := 
    for $forest in $config//*:assignments/*:assignment
    let $name := fn:string($forest/*:forest-name)
    let $js := json:object()
    let $_ := (
        map:put($js,"id",$name),
        map:put($js,"name",$name)
    )
    order by $name
    return $js
 
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
        map:put($js,"name",$name)
    )
    order by $s/*:xdbc-se
    return
       $js
return (
    map:put($json,"databases",$database),
    map:put($json,"forests",$forests),
    map:put($json,"servers",$servers),
    xdmp:set-response-content-type("application/json"),
    xdmp:to-json($json)
)
  


