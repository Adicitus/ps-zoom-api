function Remove-ZoomAPIGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true)]
        [string]$GroupID
    )
    
    $endpoint = "groups/{0}" -f $GroupID, $UserID

    Invoke-ZoomAPIRequest -Token $Token -Method Delete -Endpoint $endpoint
}