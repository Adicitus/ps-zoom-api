function Remove-ZoomAPIUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $Token,
        [Parameter(Mandatory=$true, HelpMessage="Internal ID or email of the user to remove.")]
        $UserID,
        [validateSet("Delete", "Disassociate")]
        [Parameter(Mandatory=$true)]
        $Action
    )

    $endpoint = "users/{0}" -f $UserID

    $body = @{
        action = $Action.toLower()
    }

   Invoke-ZoomAPIRequest -Token $Token -Method Delete -Endpoint $endpoint

}