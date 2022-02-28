function Get-ZoomAPIMeetingRegistrants {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true)]
        [String]$MeetingId,
        [Parameter(Mandatory=$false)]
        [String]$OccurrenceId,
        [Parameter(Mandatory=$false)]
        [ValidateSet('pending', 'approved', 'denied')]
        [String]$Status,
        [Parameter(Mandatory=$false, ParameterSetName="HostedMeetings", HelpMessage="Number of meetings to return for each request/page (max 300).")]
        [ValidateRange(1, 300)]
        [int]$PageSize,
        [Parameter(Mandatory=$false, ParameterSetName="HostedMeetings", HelpMessage="The page number of the page to return.")]
        [ValidateRange(1, 2147483647)]
        [int]$PageNumber,
        [Parameter(Mandatory=$false, ParameterSetName="HostedMeetings", HelpMessage='The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.')]
        [string]$NextPageToken
    )


    $endpoint = "meetings/{0}/registrants" -f $MeetingId

    $queryParams = [System.Collections.ArrayList]::new()

    $options = @{
        'OccurenceId'   = { param($v) $queryParams.Add('occurrence_id={0}' -f  $v) }
        'Status'        = { param($v) $queryParams.Add('status={0}' -f  $v.toLower()) }
        'PageSize'      = { param($v) $queryParams.Add('page_size={0}' -f  $v) }
        'PageNumber'    = { param($v) $queryParams.Add('page_number={0}' -f  $v)  }
        'NextPageToken' = { param($v) $queryParams.Add('next_page_token={0}' -f  $v) }
    }

    foreach ($option in $options.Keys) {
        if ($PSBoundParameters.ContainsKey($option)) {
            & $options[$option] $PSBoundParameters[$option] | Out-Null
        }
    }

    if ($queryParams.count -gt 0) {
        $endpoint += '?' + ($queryParams -join "&")
    }

    Invoke-ZoomAPIRequest -Method Get -Endpoint $Endpoint -Token $Token

}