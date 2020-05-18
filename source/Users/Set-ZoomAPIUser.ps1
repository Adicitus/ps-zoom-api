function Set-ZoomAPIUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true)]
        [String]$UserID,
        [Parameter(Mandatory=$false)]
        $FirstName,
        [Parameter(Mandatory=$false)] 
        $LastName,
        [ValidateSet("Basic", "Licensed", "OnPrem")]
        [Parameter(Mandatory=$false)]
        [string]$Type,
        [ValidatePattern("[0-9]{10}")]
        [Parameter(Mandatory=$false)]
        [string]$PrivateMeetingID,
        [Parameter(Mandatory=$false)]
        [bool]$UsePMI,
        [Parameter(Mandatory=$false, HelpMessage="List of valid TimeZones: https://marketplace.zoom.us/docs/api-reference/other-references/abbreviation-lists#timezones")]
        [string]$TimeZone,
        [Parameter(Mandatory=$false)]
        [string]$Language,
        [Parameter(Mandatory=$false)]
        [string]$Department,
        [Parameter(Mandatory=$false)]
        [string]$JobTitle,
        [Parameter(Mandatory=$false)]
        [string]$Company,
        [Parameter(Mandatory=$false)]
        [string]$Location
    )

    $endpoint = "users/{0}" -f $UserID

    $headers = @{
        "Content-Type" = "application/json"
    }

    $body = @{ }

    $map = @{
        FirstName   = { param($v) $body.first_name = $v }
        LastName    = { param($v) $body.last_name = $v }
        Type        = {
            param($v)
            $body.type = switch ($v) {
                "Basic"     { 1 }
                "Licensed"  { 2 }
                "OnPrem"    { 3 }
            }
        }
        PrivateMeetingID = { param($v) $body.pmi = $v }
        UsePMI      = { param($v) $body.use_pmi = $v }
        TimeZone    = { param($v) $body.timezone = $v }
        Language    = { param($v) $body.language = $v }
        Department  = { param($v) $body.dept = $v }
        JobTitle  = { param($v) $body.job_title = $v }
        Company  = { param($v) $body.company = $v }
        Location  = { param($v) $body.location = $v }
    }

    foreach ($key in $PSBoundParameters.Keys) {
        if ($t = $map[$Key]) {
            & $t $PSBoundParameters[$key]
        }
    }

    $jsonBody = $body | ConvertTo-Json | ConvertTo-UnicodeEscapedString

    Invoke-ZoomAPIRequest -Token $Token -Method Patch -Endpoint $endpoint -Body $jsonBody -Headers $headers

}