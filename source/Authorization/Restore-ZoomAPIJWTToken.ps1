function Restore-ZoomAPIJWTToken {
    [CmdletBinding()]
    param(
        $Path
    )

    $c = Get-Content $Path
    $ts = $c | ConvertTo-SecureString | Unlock-SecureString

    $t = $ts | ConvertFrom-Json

    $t.Token = $t.Token | ConvertTo-SecureString

    $t

}