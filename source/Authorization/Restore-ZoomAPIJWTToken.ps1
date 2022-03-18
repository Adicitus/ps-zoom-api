function Restore-ZoomAPIJWTToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, position=1)]
        [string]$Path
    )

    $c = Get-Content $Path -Encoding UTF8
    $ts = $c | ConvertTo-SecureString | Unlock-SecureString

    $t = $ts | ConvertFrom-Json

    $t.Token = $t.Token | ConvertTo-SecureString

    $t

}