function Get-ZoomAPIMeeting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true, ParameterSetName="HostedMeetings")]
        [String]$UserId,
        [Parameter(Mandatory=$true, ParameterSetName="MeetingID")]
        [String]$MeetingId
    )

    $endpoint = switch ($PSCmdlet.ParameterSetName) {
        "HostedMeetings" {
            "users/{0}/meetings" -f $UserId
        }
        "MeetingID" {
            "meetings/{0}" -f $MeetingId
        }
    }


    Invoke-ZoomAPIRequest -Method Get -Endpoint $Endpoint -Token $Token
}