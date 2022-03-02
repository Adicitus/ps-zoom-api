function Set-ZoomAPIUserActivationStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true, HelpMessage="Internal ID or email of the user to activate/deactivate.")]
        [string]$UserID,
        [ValidateSet("Active", "Inactive")]
        [Parameter(Mandatory=$true, HelpMessage="Activation status. An 'Inactive' account cannot be used to log in.")]
        [string]$ActivationStatus
    )

    $endpoint = "users/{0}/status" -f $UserID

    $headers = @{
        "Content-Type" = "application/json"
    }

    $body = @{
        action = switch ($ActivationStatus) {
            "Active" { "activate" }
            "Inactive" { "deactivate" }
        }
    } | ConvertTo-Json | ConvertTo-UnicodeEscapedString

   Invoke-ZoomAPIRequest -Token $Token -Method Put -Endpoint $endpoint -Headers $headers -Body $body

}