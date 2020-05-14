function Save-ZoomAPIJWTToken {
    [CmdletBinding()]
    param(
        $Path,
        [PSCustomObject]$JWTToken
    )

    $outString = @{
        Token = $JWTToken.Token | ConvertFrom-SecureString
        Expires = $JWTToken.Expires
        Type = $JWTToken.Type
    } | ConvertTo-Json | ConvertTo-SecureString  -AsPlainText -Force | ConvertFrom-SecureString

    $outString | Out-File -FilePath $Path
}