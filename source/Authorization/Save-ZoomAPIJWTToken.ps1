function Save-ZoomAPIJWTToken {
    [CmdletBinding(DefaultParameterSetName="TokenObject")]
    param(
        [Parameter(Mandatory=$true, position=1)]
        [string]$Path,
        [Parameter(Mandatory=$true, Position=2, ValueFromPipeline=$true, ParameterSetName="TokenObject")]
        [PSCustomObject]$Token,
        [Parameter(Mandatory=$true, Position=2, ValueFromPipeline=$true, ParameterSetName="TokenString")]
        [PSCustomObject]$JWT
    )

    if ($PSCmdlet.ParameterSetName -eq "TokenString") {
        $Token = New-ZoomAPIJWTToken $JWT
    }

    $outString = @{
        Token = $Token.Token | ConvertFrom-SecureString
        Expires = $Token.Expires
        Type = $Token.Type
    } | ConvertTo-Json | ConvertTo-SecureString  -AsPlainText -Force | ConvertFrom-SecureString

    $outString | Out-File -FilePath $Path -Encoding utf8
}