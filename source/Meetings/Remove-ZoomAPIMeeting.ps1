function Remove-ZoomAPIMeeting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true, ParameterSetName="MeetingID")]
        [String]$MeetingId
    )

    $endpoint = "Meetings/{0}" -f $MeetingId

    Invoke-ZoomAPIRequest -Token $Token -method Delete -Endpoint $Endpoint
}