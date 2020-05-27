function Reset-ZoomAPIUserPassword {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true, HelpMessage="Email-address or ID of the user to update.")]
        [String]$UserID,
        [Parameter(Mandatory=$true)]
        [SecureString]$Password
    )

    $endpoint = "users/{0}/password" -f $UserID

    $headers = @{
        "Content-Type" = "application/json"
    }

    $body = @{
        password = Unlock-SecureString $Password
    } | ConvertTo-Json | ConvertTo-UnicodeEscapedString

    Invoke-ZoomAPIRequest -Token $Token -Method Put -Endpoint $endpoint -Headers $headers -Body $body

}