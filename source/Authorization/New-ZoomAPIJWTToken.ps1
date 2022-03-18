function New-ZoomAPIJWTToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Wrap", HelpMessage="Pre-generated JWT to be wrapped for future use.")]
        [string]$Token,
        [Parameter(Mandatory=$true, ParameterSetName="Generate", HelpMessage="API Key to use for the token. This will be included into the JWT as issuer.")]
        [SecureString]$APIKey,
        [Parameter(Mandatory=$true, ParameterSetName="Generate", HelpMessage="Client Secret to use for the token. This will be used to sign the token.")]
        [securestring]$ClientSecret,
        [Parameter(Mandatory=$false, ParameterSetName="Generate", HelpMessage="Expiration time for the tokem. This will be used to set the exp field of the token. NOTICE: as of this writing Zoom servers do not check exp, but that may change in the future.")]
        [Int32]$ExpirationTimeSeconds = 60
    )

    $jwt = $null
    $expirationTime = $null

    switch ($PSCmdlet.ParameterSetName) {

        Wrap {
            $jwt = $Token
            $h, $p, $s = $jwt.split('.')

            # Pad the base64 string if necessary (to mkae it divisible by 4):
            if (($m = $p.length % 4) -ne 0) {
                $p += "=" * (4 - $m)
            }

            $pb = [convert]::FromBase64String($p)
            $ps = [System.Text.Encoding]::UTF8.getString($pb)
            $po = $ps | ConvertFrom-Json

            $expUnix    = $po.exp
            $exp        = ([datetime]"1970-01-01").AddSeconds($expUnix)

            $expirationTime = $exp
        }

        Generate {
            $header = @{
                "alg" = "HS256"
                "typ" = "JWT"
            } | ConvertTo-Json

            $headerBytes    = [System.Text.Encoding]::ASCII.GetBytes($header)
            $headerB64S     = [convert]::ToBase64String($headerBytes)

            $expirationTime = [datetime]::now.AddSeconds($ExpirationTimeSeconds)
            $expirationTimeUnix = [math]::Round( ($expirationTime - [datetime]"1970-01-01").TotalSeconds )

            "Expiration unix timestamp: {0}" -f $expirationTimeUnix | Write-Debug

            $payload = @{
                "iss" = Unlock-SecureString $APIKey
                "exp" = $expirationTimeUnix
            } | ConvertTo-Json
            
            $payloadBytes   = [System.Text.Encoding]::ASCII.GetBytes($payload)
            $payloadB64S    = [convert]::ToBase64String($payloadBytes)

            $message = $headerB64S, $payloadB64S -join "."

            $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
            $hmacsha.Key = [System.Text.Encoding]::ASCII.GetBytes((Unlock-SecureString $ClientSecret))
            $signatureBytes = $hmacsha.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($message))
            $signatureB64S = [convert]::ToBase64String($signatureBytes)

            $jwt = $message, $signatureB64S -join "."
        }
    }

    return [PSCustomObject]@{
        Type="JWT"
        Token = ConvertTo-SecureString -AsPlainText -Force -String $jwt
        Expires = $expirationTime
    }
}