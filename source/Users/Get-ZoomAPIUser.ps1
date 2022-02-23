function Get-ZoomAPIUser {
    [CmdletBinding(DefaultParameterSetName="ListUsers")]
    param(
        [Parameter(Mandatory=$true)]
        $Token,
        [Parameter(Mandatory=$true, ParameterSetName="SingleUser", HelpMessage="Internal ID or email of the user to retrieve.")]
        [string]$UserID,
        [Parameter(Mandatory=$false, ParameterSetName="ListUsers", HelpMessage="Status of the user ('active', 'inactive' or 'pending').")]
        [ValidateSet('active', 'inactive', 'pending')]
        [string]$Status,
        [Parameter(Mandatory=$false, ParameterSetName="ListUsers", HelpMessage="Number of users to return for each request (max 300).")]
        [ValidateRange(1, 300)]
        [int]$PageSize,
        [Parameter(Mandatory=$false, ParameterSetName="ListUsers", HelpMessage="The page number of the page to return.")]
        [ValidateRange(1, 2147483647)]
        [int]$PageNumber,
        [Parameter(Mandatory=$false, ParameterSetName='ListUsers', HelpMessage='Returns users with the given role.')]
        [string]$RoleId,
        [Parameter(Mandatory=$false, ParameterSetName='ListUsers', HelpMessage='The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.')]
        [string]$NextPageToken,
        [Parameter(Mandatory=$false, ParameterSetName='ListUsers', HelpMessage='The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.')]
        [ValidateSet('custom_attributes', 'host_key')]
        [string]$IncludeFields
    )

    $endpoint = "users"

   switch ($PSCmdlet.ParameterSetName) {
        'ListUsers'  {

            $headers = @{
                'Content-Type' = 'application/json'
            }

            $queryParams = [System.Collections.ArrayList]::new()

            $options = @{
                'Status'        = { param($v) $queryParams.Add('status={0}' -f  $v.toLower()) }
                'PageSize'      = { param($v) $queryParams.Add('page_size={0}' -f  $v) }
                'PageNumber'    = { param($v) $queryParams.Add('page_number={0}' -f  $v)  }
                'RoleId'        = { param($v) $queryParams.Add('role_id={0}' -f  $v) }
                'IncludeFields' = { param($v) $queryParams.Add('include_fields={0}' -f  $v.toLower())  }
                'NextPageToken' = { param($v) $queryParams.Add('next_page_token={0}' -f  $v) }
            }

            foreach ($option in $options.Keys) {
                if ($PSBoundParameters.ContainsKey($option)) {
                    & $options[$option] $PSBoundParameters[$option]
                }
            }

            if ($queryParams.count -gt 0) {
                $endpoint += '?' + ($queryParams -join "&")
            }

            return Invoke-ZoomAPIRequest -Token $Token -Method Get -Endpoint $endpoint -Headers $headers
        }

        'SingleSUer' {
            $endpoint += "/{0}" -f $UserID
            return Invoke-ZoomAPIRequest -Token $Token -Method Get -Endpoint $endpoint
        }
   }

   

}