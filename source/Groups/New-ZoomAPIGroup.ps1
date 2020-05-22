function New-ZoomAPIGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    $entrypoint = "groups"

    $headers = @{
        "Content-Type" = "application/json"
    }

    $body = @{
        name = $Name
    } | ConvertTo-Json | ConvertTo-UnicodeEscapedString

    Invoke-ZoomAPIRequest -Token $Token -Method Post -Endpoint $endpoint -Body $body -Headers $headers
}