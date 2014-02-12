xquery version "1.0-ml";

import module namespace setup = "http://marklogic.com/ps/setup" at "lib-setup.xqy";
declare namespace sec="http://marklogic.com/xdmp/security";

let $filename := xdmp:get-request-field("filename","config.xml")
let $databases := xdmp:get-request-field("databases", "")
let $forests := xdmp:get-request-field("forests", "")
let $servers := xdmp:get-request-field("servers", "")
let $user-ids as xs:unsignedLong* := 
  for $x in xdmp:get-request-field("users", ())
  return
    xs:unsignedLong($x)
let $role-ids as xs:unsignedLong* :=
  for $x in xdmp:get-request-field("roles", ())
  return
    xs:unsignedLong($x)
let $submit := xdmp:get-request-field("submit", "")
let $_ := xdmp:log(($role-ids,$user-ids))
return
if ($submit eq "Export") then
  let $_ := xdmp:set-response-content-type("text/xml") 
  let $config := setup:get-configuration($databases, $forests, $servers, $user-ids, $role-ids, ())
  let $type := xdmp:add-response-header("Content-Type", "text/xml")
  let $disp := xdmp:add-response-header("Content-Disposition", "attachment; filename=" || $filename)
  return $config
  
else ()

