function New-ZoomAPIGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    $endpoint = "groups"

    $headers = @{
        "Content-Type" = "application/json"
    }

    $body = @{
        name = $Name
    } | ConvertTo-Json | ConvertTo-UnicodeEscapedString

    Invoke-ZoomAPIRequest -Token $Token -Method Post -Endpoint $endpoint -Body $body -Headers $headers
}