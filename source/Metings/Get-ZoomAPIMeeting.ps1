function Get-ZoomAPIMeeting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true, ParameterSetName="HostedMeetings")]
        [String]$UserId,
        [Parameter(Mandatory=$true, ParameterSetName="MeetingID")]
        [String]$MeetingId,
        [Parameter(Mandatory=$false, ParameterSetName="HostedMeetings", HelpMessage="Type of meeting to retrieve.")]
        [ValidateSet('scheduled', 'upcomig', 'live')]
        [String]$Type,
        [Parameter(Mandatory=$false, ParameterSetName="HostedMeetings", HelpMessage="Number of meetings to return for each request/page (max 300).")]
        [ValidateRange(1, 300)]
        [int]$PageSize,
        [Parameter(Mandatory=$false, ParameterSetName="HostedMeetings", HelpMessage="The page number of the page to return.")]
        [ValidateRange(1, 2147483647)]
        [int]$PageNumber,
        [Parameter(Mandatory=$false, ParameterSetName="HostedMeetings", HelpMessage='The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.')]
        [string]$NextPageToken
    )
    
    $endpoint = $null

    switch ($PSCmdlet.ParameterSetName) {
        "HostedMeetings" {
            $endpoint = "users/{0}/meetings" -f $UserId

            $options = @{
                'Type'          = { param($v) 'type={0}' -f  $v.toLower() }
                'PageSize'      = { param($v) 'page_size={0}' -f  $v }
                'PageNumber'    = { param($v) 'page_number={0}' -f  $v  }
                'NextPageToken' = { param($v) 'next_page_token={0}' -f  $v }
            }

            Invoke-ZoomAPIRequest -Method Get -Endpoint $Endpoint -Token $Token -QueryParamMap $options -QueryParamSrc $PSBoundParameters
        }
        "MeetingID" {
            $endpoint = "meetings/{0}" -f $MeetingId
            Invoke-ZoomAPIRequest -Method Get -Endpoint $Endpoint -Token $Token
        }
    }


    
}