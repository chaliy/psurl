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
    Optional parameter to dowload stuff to the file.
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
    [HashTable]$Data,
    [String]$Content,
    [TimeSpan]$Timeout = [TimeSpan]::FromMinutes(1),
    [Management.Automation.PSCredential]$Credential,
    [String]$ContentType
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
        
        if ($Content -ne ""){
            $reqStream = $req.GetRequestStream()
            $reqBody = [Text.Encoding]::Default.GetBytes($Content)
            $reqStream.Write($reqBody, 0, $reqBody.Length)
            
        } else {
        
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
    Adds Content-Type header to request
.Example
    Write-Url http://chaliy.name -Data @{"Foo" = "Bar" }

    Description
    -----------
    POST's to the http://chaliy.name as application/x-www-form-urlencoded

#>
}


Export-ModuleMember Get-Url
Export-ModuleMember Write-Url