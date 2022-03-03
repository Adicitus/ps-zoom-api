function Add-ZoomAPIGroupMembers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true, HelpMessage="ID of the group that the users should be added to.")]
        [string]$GroupID,
        [Parameter(Mandatory=$true, HelpMessage="User IDs and/or email addresses of the users to add. If more than 30 members are specified, this command will perform multiple calls to the API.")]
        [String[]]$Members
    )

    if ($members.count) {
        "More than 30 members specified. The Zoom API is limited to adding 30 members at-a-time. Multiple calls will be made to add all the users." | Write-Warning
    }

    $endpoint = "groups/{0}/members" -f $GroupID

    $headers = @{
        "Content-Type" = "application/json"
    }

    $emailRegex = "[a-z0-9\.\-_]+@([a-z0-9\-_]+\.)+[a-z0-9]+"

    $batchNumber = 0

    do {

        $body = @{
            members = @()
        }

        $batchStart = $batchNumber * 30
        $batchSize = 30
        if (($batchStart + $batchSize) -gt $Members.Count) {
            $batchSize = $members.Count - $batchStart
        }
        $batchEnd = $batchStart + $batchSize - 1 

        $batchMembers = $members[$batchStart..$batchEnd]

        foreach ($member in $batchMembers) {
            $body.members += if ($member -match $emailRegex) {
                @{ email = $member }
            } else {
                @{ id = $member }
            }
        }

        $jsonBody = $body | ConvertTo-Json | ConvertTo-UnicodeEscapedString
    
        Invoke-ZoomAPIRequest -Token $Token -Method Post -Endpoint $endpoint -Headers $headers -Body $jsonBody

        $batchNumber++
    } while($batchNumber * 30 -le $members.Count)

}