function Get-ZoomAPIGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        $Token,
        [Parameter(Mandatory=$false)]
        $GroupID
    )
    
    $endpoint = "groups"

    if ($GroupID) {
        $endpoint += "/{0}" -f $GroupID
    }

    Invoke-ZoomAPIRequest -Token $Token -Method Get -Endpoint $endpoint
}