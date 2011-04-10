##
##    Inspired by curl, adds some commands to work with web.
##

function Get-Url {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    [String]$Url
)
    (new-object System.Net.WebClient).DownloadString($Url)
<#
.Synopsis
    Downloads from url as a string.
.Description     
.Parameter Url
    URL to download
.Example
    Get-Url http://chaliy.name

    Description
    -----------
    Downloads content of the http://chaliy.name

#>
}

Export-ModuleMember Get-Url
