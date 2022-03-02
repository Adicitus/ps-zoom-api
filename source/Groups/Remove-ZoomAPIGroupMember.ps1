function Remove-ZoomAPIGroupMember {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true)]
        [string]$GroupID,
        [Parameter(Mandatory=$true, HelpMessage="ID or Email of the user to remove from the group.")]
        [String]$UserID
    )


    $emailregex = "[a-z0-9\.\-_]+@([a-z0-9\-_]+\.)+[a-z0-9]+"
    if ($UserID -match $emailregex) {
        $userR = Get-ZoomAPIUser -Token $Token -UserID $UserID

        if ($userR.statusCode -eq 200) {
            $UserID = $userR.Content.id
        } else {
            Throw "Unable to translate user email to User ID."
        }
    }
    
    $endpoint = "groups/{0}/members/{1}" -f $GroupID, $UserID

    Invoke-ZoomAPIRequest -Token $Token -Method Delete -Endpoint $endpoint
}