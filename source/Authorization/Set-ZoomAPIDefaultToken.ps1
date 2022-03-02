function Set-ZoomAPIDefaultToken {
    param(
        [parameter(Mandatory=$true)]
        [PSCustomObject]$Token
    )

    $script:defaultToken = $Token
}