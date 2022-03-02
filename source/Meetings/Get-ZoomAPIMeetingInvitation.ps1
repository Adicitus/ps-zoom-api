function Get-ZoomAPIMeetingInvitation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true)]
        [String]$MeetingId
    )

    $endpoint = "meetings/{0}/invitation" -f $MeetingID

    Invoke-ZoomAPIRequest -Method Get -Endpoint $endpoint -Token $Token
}