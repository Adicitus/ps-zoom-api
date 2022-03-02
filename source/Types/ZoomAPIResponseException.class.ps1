<#
.SYNOPSIS
Exception used to signal a API error in ContentOnly mode.

.DESCRIPTION
Exception used to signal a API error in ContentOnly mode.

StatusCode: The HTTP status code returned by the server.
ErrorCode: The Zoom API error code returned by the server.
ErrorDescription: The description of the Zoom APi Error code returned by the server.

#>
class ZoomAPIResponseException : Exception {
    [int]$StatusCode
    [int]$ErrorCode
    [string]$ErrorDescription

    ZoomAPIResponseException([int]$StatusCode, [int]$ErrorCode, [string]$ErrorDescription) : Base(('Received status code {0}. Error code {1} ({2})' -f $StatusCode, $ErrorCode, $ErrorDescription)) {
        $this.StatusCode        = $StatusCode
        $this.ErrorCode         = $ErrorCode
        $this.ErrorDescription  = $ErrorDescription 
    }
}