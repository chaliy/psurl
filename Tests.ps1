$here = (Split-Path -parent $MyInvocation.MyCommand.Definition)
import-module -name ($here + "\PsUrl\PsUrl.psm1") -force

write-host Should support downloading stuff
get-webcontent "http://example.com" | out-null

write-host Should support 404
get-webcontent "http://us.blizzard.com/en-us/404/" -ErrorAction:SilentlyContinue

write-host Should support downloading to file
get-url "http://example.com" -ToFile "$here\example.html"
if (-not (test-path "$here\example.html")){ write-error "example.html was not downloaded" }
remove-item "$here\example.html"

write-host Should support posting stuff
send-webcontent "http://example.com" -Data @{"Foo" = "Bar"} | out-null

