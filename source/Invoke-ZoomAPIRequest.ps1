function Invoke-ZoomAPIRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
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

    $uri = "https://api.zoom.us/v2/{0}" -f $Endpoint

    # Build query string:
    $queryParams = [System.Collections.ArrayList]::new()

    foreach ($param in $QueryParamMap.Keys) {
        if ($QueryParamSrc.ContainsKey($param)) {
            $p = & $options[$param] $QueryParamSrc[$param]
            "TRANSFORM: {0}({1}) => '{2}'" -f $param, $QueryParamSrc[$param], $p | Write-Debug
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

    $r = try {
        '{0,-7} {1}' -f $requestArgs.method.toUpper(), $requestArgs.uri | Write-Debug
        Invoke-WebRequest @requestArgs -UseBasicParsing
    } catch {
        return $_
    }

    $response = @{
        _raw = $r
    }

    switch ($r.GetType().Name) {
        "ErrorRecord" {
            $d = $r.ErrorDetails.message | ConvertFrom-Json
            $response.StatusCode = $d.code
            $response.Content = $d.message
        }

        "BasicHtmlWebResponseObject" {
            $response.StatusCode = $r.StatusCode
            $response.Content = $r.Content | ConvertFrom-UnicodeEscapedString | ConvertFrom-Json
        }

        "WebResponseObject" {
            $response.StatusCode = $r.StatusCode
            $response.Content = $r.Content | ConvertFrom-UnicodeEscapedString | ConvertFrom-Json
        }

        default {
            $response.StatusCode = -1
        }
    }

    return $response

}