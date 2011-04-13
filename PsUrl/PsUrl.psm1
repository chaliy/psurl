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

function Write-Url {
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
	try{
 		$result = $client.UploadValues($Url, $preparedData)
		[System.Text.Encoding]::Default.GetString($result)
	}
	catch [System.Net.WebException]{
 		$errorResult = $_.Exception.Response.GetResponseStream()
		$errorText = (New-Object System.IO.StreamReader($errorResult)).ReadToEnd()
		Write-Error "The remote server response: $errorText"
		throw $_
	}	
	
<#
.Synopsis
    POST values to URL
.Description     
.Parameter Url
    URL to POST
.Example
    Write-Url http://chaliy.name -Data @{"Foo" = "Bar" }

    Description
    -----------
    POST's to the http://chaliy.name as application/x-www-form-urlencoded

#>
}

Export-ModuleMember Get-Url
Export-ModuleMember Write-Url
