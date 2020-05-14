function Invoke-ZoomAPIRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Token,
        [ValidateSet("Get", "Post", "Patch", "Delete", "Put")]
        [Parameter(Mandatory=$true)]
        [String]$Method,
        [Parameter(Mandatory=$true)]
        [string]$Endpoint,
        [Parameter(Mandatory=$false)]
        [hashtable]$Headers,
        [Parameter(Mandatory=$false)]
        [string]$Body
    )

    $uri = "https://api.zoom.us/v2/{0}" -f $Endpoint

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
        Invoke-WebRequest @requestArgs -UseBasicParsing
    } catch {
        $_
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