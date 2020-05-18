function Get-ZoomAPIUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $Token,
        [Parameter(Mandatory=$false, HelpMessage="Internal ID or email of the user to retrieve.")]
        $UserID
    )

    $endpoint = "users"

    if ($UserID) {
        $endpoint += "/{0}" -f $UserID
    }

   Invoke-ZoomAPIRequest -Token $Token -Method Get -Endpoint $endpoint

}