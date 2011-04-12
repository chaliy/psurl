##
##    Inspired by curl, adds some commands to work with web.
##

function Get-Url {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    [String]$Url
)
    (New-Object System.Net.WebClient).DownloadString($Url)
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

function Post-Url {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    [String]$Url,
	[HashTable]$Data
)
    $client = (New-Object System.Net.WebClient)
	$preparedData = (New-Object System.Collections.Specialized.NameValueCollection)
	
	foreach($key in $Data.Keys){
		$preparedData.Add($key, $Data[$key])
	}	
	
	$client.UploadValues($Url, $preparedData)
	
<#
.Synopsis
    POST values to URL
.Description     
.Parameter Url
    URL to POST
.Example
    Post-Url http://chaliy.name -Data @{"Foo" = "Bar" }

    Description
    -----------
    POST's to the http://chaliy.name as application/x-www-form-urlencoded

#>
}

Export-ModuleMember Get-Url
