function Set-ZoomAPIResponseStyle {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$false, HelpMessage="Style of reponse. 'Detailed' will include full details including status code, 'ContentOnly' will return only the content of responses.")]
        [ResponseStyle]$ResponseStyle
    )

    $script:ResponseDetails = $ResponseStyle
}