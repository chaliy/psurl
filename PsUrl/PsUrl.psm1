##
##    Inspired by curl, adds some commands to work with web.
##

function Get-Url {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    [String]$Url,
    [String]$ToFile,
    [Management.Automation.PSCredential]$Credential
)
    Write-Verbose "Get-Url is considered obsolete. Please use Get-WebContent instead"

    $client = (New-Object Net.WebClient)
    if ($Credential){
        $ntwCred = $Credential.GetNetworkCredential()
        $client.Credentials = $ntwCred        
        $auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::Default.GetBytes($ntwCred.UserName + ":" + $ntwCred.Password))
        $client.Headers.Add("Authorization", $auth)
    }

    if ($ToFile -ne ""){
        $client.DownloadFile($Url, $ToFile)    
    } else {
        $client.DownloadString($Url)
    }
<#
.Synopsis
    Downloads from url as a string.
.Description     
.Parameter Url
    URL to download
.Parameter ToFile
    Optional parameter to download stuff to the file.
.Example
    Get-Url http://chaliy.name

    Description
    -----------
    Downloads content of the http://chaliy.name

#>
}

function Get-WebContent {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    [String]$Url,
    [Management.Automation.PSCredential]$Credential,
    $Encoding
)
    $client = (New-Object Net.WebClient)
    if ($Credential){
        $ntwCred = $Credential.GetNetworkCredential()
        $client.Credentials = $ntwCred        
        $auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::Default.GetBytes($ntwCred.UserName + ":" + $ntwCred.Password))
        $client.Headers.Add("Authorization", $auth)
    }    
    if ($Encoding){
        if ($Encoding -is [string]){
            $Encoding = [Text.Encoding]::GetEncoding($Encoding)
        }
        $client.Encoding = $Encoding        
    }

    try {
        $client.DownloadString($Url)    
    } catch [System.Net.WebException] {
        throw "Request failed: ""$($_.Exception.Message)"""
    }
    
<#
.Synopsis
    Downloads content from given url as a string.
.Description     
.Parameter Url
    URL to download
.Parameter Credential
    Optional parameter to specified basic authorization credentials
.Parameter Encoding
    Optional parameter to specified encoding of the content(e.g. Utf-8)
.Example
    Get-WebContent http://chaliy.name

    Description
    -----------
    Downloads content of the http://chaliy.name

.Example
    Get-WebContent http://chaliy.name -Encoding Utf-8

    Description
    -----------
    Downloads content of the http://chaliy.name with UTF-8 encoding

.Link
    Send-WebContent

#>
}

function Write-Url {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    [String]$Url,
    [HashTable]$Data,
    [String]$Content,
    [TimeSpan]$Timeout = [TimeSpan]::FromMinutes(1),
    [Management.Automation.PSCredential]$Credential,
    [String]$ContentType
)    
    Write-Verbose "Write-Url is considered obsolete. Please use Send-WebContent instead"
    if ($Content -ne ""){
        Send-WebContent -Url:$Url -Content:$Content -Timeout:$Timeout -Credential:$Credential -ContentType:$ContentType
    }  else {
        Send-WebContent -Url:$Url -Data:$Data -Timeout:$Timeout -Credential:$Credential -ContentType:$ContentType
    }
<#
.Synopsis
    POST values to URL
.Description     
.Parameter Url
    URL to POST
.Parameter Data
    Hashtable of the data to post.
.Parameter Timeout
    Optional timeout value, by default timeout is 1 minute.
.Parameter ContentType
    Adds Content-Type header to request
.Example
    Write-Url http://chaliy.name -Data @{"Foo" = "Bar" }

    Description
    -----------
    POST's to the http://chaliy.name as application/x-www-form-urlencoded

#>
}


function Send-WebContent {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    [String]$Url,
    [Parameter(ParameterSetName='Data')]
    [HashTable]$Data,
    [Parameter(ParameterSetName='Content')]
    [String]$Content,
    [TimeSpan]$Timeout = [TimeSpan]::FromMinutes(1),
    [Management.Automation.PSCredential]$Credential,
    [String]$ContentType,
    [HashTable]$Headers
)    
    

    try{
        $req = [Net.WebRequest]::Create($Url)
        $req.Method = "POST"
        $req.Timeout = $Timeout.TotalMilliseconds
        if ($Credential){
            $ntwCred = $Credential.GetNetworkCredential()
            $auth = "Basic " + [Convert]::ToBase64String([Text.Encoding]::Default.GetBytes($ntwCred.UserName + ":" + $ntwCred.Password))
            $req.Headers.Add("Authorization", $auth)
            $req.Credentials = $ntwCred
            $req.PreAuthenticate = $true
        }

        if ($ContentType -ne ""){
            $req.ContentType = $ContentType
        }

        if ($Headers -ne $Null){
            foreach($headerName in $Headers.Keys){
                $req.Headers.Add($headerName, $Headers[$headerName])
            }
        }

        switch($PSCmdlet.ParameterSetName) {
            Content { 
                $reqStream = $req.GetRequestStream()
                $reqBody = [Text.Encoding]::Default.GetBytes($Content)
                $reqStream.Write($reqBody, 0, $reqBody.Length)
            }
            Data {
                Add-Type -AssemblyName System.Web
                $formData = [Web.HttpUtility]::ParseQueryString("")
                foreach($key in $Data.Keys){
                    $formData.Add($key, $Data[$key])
                }
                $reqBody = [Text.Encoding]::Default.GetBytes($formData.ToString())
            
                $req.ContentType = "application/x-www-form-urlencoded"
                $reqStream = $req.GetRequestStream()
                $reqStream.Write($reqBody, 0, $reqBody.Length)
            }
        }
               
        $reqStream.Close()
        
        $Method = $req.Method
        Write-Verbose "Execute $Method request"
        foreach($header in $req.Headers.Keys){
            Write-Verbose ("$header : " + $req.Headers[$header])
        }
                
        $resp = $req.GetResponse()
        $respStream = $resp.GetResponseStream()
        $respReader = (New-Object IO.StreamReader($respStream))
        $respReader.ReadToEnd()
    }
    catch [Net.WebException]{
        if ($_.Exception -ne $null -and $_.Exception.Response -ne $null) {
            $errorResult = $_.Exception.Response.GetResponseStream()
            $errorText = (New-Object IO.StreamReader($errorResult)).ReadToEnd()
            Write-Error "The remote server response: $errorText"
        }
        throw $_
    }

<#
.Synopsis
    POST values to URL
.Description     
.Parameter Url
    URL to POST
.Parameter Data
    Hashtable of the data to post.
.Parameter Timeout
    Optional timeout value, by default timeout is 1 minute.
.Parameter ContentType
    Adds Content-Type header to the request
.Parameter Headers
    Adds arbitrary headers to the request
.Example
    Send-WebContent http://chaliy.name -Data @{"Foo" = "Bar" }

    Description
    -----------
    POST's to the http://chaliy.name as application/x-www-form-urlencoded

.Link
    Get-WebContent
#>
}


Export-ModuleMember Get-Url #Obsolete
Export-ModuleMember Write-Url #Obsolete

Set-Alias gwc Get-WebContent
Set-Alias swc Send-WebContent
Export-ModuleMember Get-WebContent
Export-ModuleMember Send-WebContent
Export-ModuleMember -Alias gwc
Export-ModuleMember -Alias swc