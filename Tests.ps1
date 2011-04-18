$here = (Split-Path -parent $MyInvocation.MyCommand.Definition)
import-module -name ($here + "\PsUrl\PsUrl.psm1")

write-host Should support downloading stuff
get-url "http://example.com" | out-null

write-host Should support downloading to file
get-url "http://example.com" -ToFile "example.html"
if (-not (test-path "example.html")){ write-error "example.html was not downloaded" }
remove-item "example.html"

write-host Should support posting stuff
write-url "http://example.com" -Data @{"Foo" = "Bar"} | out-null