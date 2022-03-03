function Invoke-ZoomAPIRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$Token,
        [ValidateSet("Get", "Post", "Patch", "Delete", "Put")]
        [Parameter(Mandatory=$true,  HelpMessage="The HTTP method to use.")]
        [String]$Method,
        [Parameter(Mandatory=$true,  HelpMessage="The endpoint to send the request to.")]
        [string]$Endpoint,
        [Parameter(Mandatory=$false, HelpMessage="HTTP headers to send.")]
        [hashtable]$Headers,
        [Parameter(Mandatory=$false, HelpMessage="Body to include with the request. If omitted no body will be sent.")]
        [string]$Body,
        [Parameter(Mandatory=$false, HelpMessage="Hashtable mapping Parameter names to scriptblocks used to transform parameter values to Zoom API query params.")]
        [hashtable]$QueryParamMap = @{},
        [Parameter(Mandatory=$false, HelpMessage="Hashtable mapping parameter names to parameter values.")]
        [hashtable]$QueryParamSrc = @{}
    )

    if (!$Token) {
        $Token = Get-ZoomAPIDefaultToken
    }

    $uri = "https://api.zoom.us/v2/{0}" -f $Endpoint

    # Build query string:
    $queryParams = [System.Collections.ArrayList]::new()

    foreach ($param in $QueryParamMap.Keys) {
        if ($QueryParamSrc.ContainsKey($param)) {
            $p = & $options[$param] $QueryParamSrc[$param]
            "ZoomAPI TRANSFORM {0}({1}) => '{2}'" -f $param, $QueryParamSrc[$param], $p | Write-Debug
            $queryParams.Add($p) | Out-Null
        }
    }

    if ($queryParams.count -gt 0) {
        $uri += '?' + ($queryParams -join "&")
    }

    $headers = if ($PSBoundParameters.containsKey("Headers")) {
        $Headers.clone()
    } else {
        @{}
    }

    $headers.Authorization = "Bearer {0}" -f (Unlock-SecureString $Token.Token)

    $requestArgs = @{
        Method = $Method
        Uri = $Uri
        Headers = $headers
    }

    if($PSBoundParameters.containsKey("Body")) {
        $requestArgs.Body = $Body
    }

    $response = @{}

    $r = try {
        'ZoomAPI {0,-9} {1}' -f $requestArgs.method.toUpper(), $requestArgs.uri | Write-Debug
        $r = Invoke-WebRequest @requestArgs -UseBasicParsing
        $response._raw = $r
    } catch {
        $response._raw = $_
    }

    $raw = $response._raw

    switch -Regex ($raw.GetType().Name) {
        "^ErrorRecord$" {
            $d = $raw.ErrorDetails.message | ConvertFrom-Json
            $raw.Exception.Response.StatusCode | Write-Debug
            $response.StatusCode = [int]$raw.Exception.Response.StatusCode
            $response.ErrorCode  = $d.code 
            $response.Content = $d.message
        }

        "^(BasicHtmlWebResponseObject|WebResponseObject)$" {

            $response.StatusCode = $raw.StatusCode
            $response.Content = $raw.Content | ConvertFrom-UnicodeEscapedString | ConvertFrom-Json
        }

        default {
            $response.StatusCode = -1
        }
    }

    if ($script:ResponseDetails -eq [ResponseStyle]::ContentOnly) {
        if ($response.ErrorCode) {
            throw [ZoomAPIResponseException]::new($response.StatusCode, $response.ErrorCode, $response.Content)
        }
        return $response.Content
    } else {
        return $response
    }

}