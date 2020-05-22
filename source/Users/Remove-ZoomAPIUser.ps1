function Remove-ZoomAPIUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $Token,
        [Parameter(Mandatory=$true, HelpMessage="Internal ID or email of the user to remove.")]
        $UserID,
        [validateSet("Delete", "Disassociate")]
        [Parameter(Mandatory=$false, HelpMessage="Delete: Remove user completely. Disassociate: Remove user from the Account but keep it as a separate account. (Default: Disassociate)")]
        $Action="Disassociate"
    )

    $endpoint = "users/{0}" -f $UserID

    $headers = @{
        "Content-Type" = "application/json"
    }

    $body = @{
        action = $Action.toLower()
    }

    $jsonBody = $body | ConvertTo-Json | ConvertTo-UnicodeEscapedString

    Invoke-ZoomAPIRequest -Token $Token -Method Delete -Endpoint $endpoint -Body $jsonBody -Headers $headers

}