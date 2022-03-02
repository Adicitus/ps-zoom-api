function Add-ZoomAPIGroupMembers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true)]
        [string]$GroupID,
        [Parameter(Mandatory=$true, HelpMessage="User IDs and/or email addresses of the users to add.")]
        [String[]]$Members
    )

    $endpoint = "groups/{0}/members" -f $GroupID

    $headers = @{
        "Content-Type" = "application/json"
    }

    $body = @{
        members = @()
    }

    $emailRegex = "[a-z0-9\.\-_]+@([a-z0-9\-_]+\.)+[a-z0-9]+"
    foreach ($member in $members) {
        $body.members += if ($member -match $emailRegex) {
            @{ email = $member }
        } else {
            @{ id = $member }
        }
    }

    $jsonBody = $body | ConvertTo-Json | ConvertTo-UnicodeEscapedString

    Invoke-ZoomAPIRequest -Token $Token -Method Post -Endpoint $endpoint -Headers $headers -Body $jsonBody

}