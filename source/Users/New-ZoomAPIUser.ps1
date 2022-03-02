function New-ZoomAPIUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true)]
        [string]$Email,
        [Parameter(Mandatory=$false)]
        $FirstName,
        [Parameter(Mandatory=$false)] 
        $LastName,
        [ValidateSet("Basic", "Licensed", "OnPrem")]
        [Parameter(Mandatory=$false)]
        [string]$Type="Basic",
        [ValidateSet(
            "create", # User will get an email sent from Zoom for confirmation, user can set their password.
            "autoCreate", # For users belonging to a managed domain.
            "custCreate",
            "ssoCreate"
        )]
        [Parameter(Mandatory=$false)]
        [string]$Action="create"
    )

    $endpoint = "users"

    $headers = @{
        "Content-Type" = "application/json"
    }

    $body = @{
        action = $Action
        user_info = @{
            email = $email
        }
    }

    $body.user_info.type = switch ($Type) {
        "Basic"     { 1 }
        "Licensed"  { 2 }
        "OnPrem"    { 3 }
    }

    if ($FirstName) {
        $body.user_info."first_name" = $FirstName
    }

    if ($LastName) {
        $body.user_info."last_name" = $LastName
    }

    $jsonBody = $body | ConvertTo-Json | ConvertTo-UnicodeEscapedString

    Invoke-ZoomAPIRequest -Token $Token -Method Post -Endpoint $endpoint -Body $jsonBody -Headers $headers

}