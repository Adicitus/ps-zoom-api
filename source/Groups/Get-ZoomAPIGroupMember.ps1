function Get-ZoomAPIGroupMembers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $Token,
        [Parameter(Mandatory=$true)]
        $GroupID
    )

    $endpoint = "groups/{0}/members" -f $GroupID

    Invoke-ZoomAPIRequest -Token $Token -Method Get -Endpoint $endpoint

}