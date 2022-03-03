function Get-ZoomAPIPlanUsageReport {
    param(
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$false)]
        [string]$AccountId="me"
    )

    $endpoint = 'accounts/{0}/plans/usage' -f $AccountId

    Invoke-ZoomAPIRequest -Token $Token -Endpoint $endpoint -Method Get
}