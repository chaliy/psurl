$here = (Split-Path -parent $MyInvocation.MyCommand.Definition)
import-module -name ($here + "\PsUrl\PsUrl.psm1")

write-host Should support downloading stuff
get-url "http://example.com" | Out-Null

write-host Should support posting stuff
write-url "http://example.com" -Data @{"Foo" = "Bar"}