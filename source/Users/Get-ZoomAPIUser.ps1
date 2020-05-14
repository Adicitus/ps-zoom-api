function Get-ZoomAPIUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $Token,
        [Parameter(Mandatory=$false)]
        $Id
    )

    $endpoint = "users"

    if ($Id) {
        $endpoint += "/{0}" -f $Id
    }

   Invoke-ZoomAPIRequest -Token $Token -Method Get -Endpoint $endpoint

}