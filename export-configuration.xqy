xquery version "1.0-ml";

declare namespace sec="http://marklogic.com/xdmp/security";
let  $json := json:object()
let $databases := for $db in xdmp:database-name(xdmp:databases()) order by $db return $db
let $forests := for $f in xdmp:forest-name(xdmp:forests()) order by $f return $f
let $servers := for $s  in xdmp:server-name(xdmp:servers()) order by $s return $s
let $users :=  
    for $user in xdmp:eval("/sec:user", (), 
        <options xmlns="xdmp:eval">
          <database>{xdmp:database("Security")}</database>
        </options>)
    let $jso := json:object() 
    let $_   := map:put($jso,"name",fn:data($user/sec:user-name))
    let $_   := map:put($jso,"id", fn:data($user/sec:user-id))
    order by $user/sec:user-name
    return  
       $jso
let $roles :=         
    for $role in xdmp:eval("/sec:role", (),
    <options xmlns="xdmp:eval">
          <database>{xdmp:database("Security")}</database>
    </options>)
    let $jso := json:object()
    let $_   := map:put($jso,"name",fn:data($role/sec:role-name))
    let $_   := map:put($jso,"id", fn:data($role/sec:role-id))
    order by $role/sec:role-name
    return  
       $jso
return
    (
       map:put($json,"databases",$databases),
       map:put($json,"forests",$forests),
       map:put($json,"servers",$servers),
       map:put($json,"roles",$roles),
       map:put($json,"users",$users),
       xdmp:set-response-content-type("application/json"),
       xdmp:to-json($json)
       )