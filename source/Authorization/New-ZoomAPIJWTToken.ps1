function New-ZoomAPIJWTToken {
    [CmdletBinding()]
    param(
        [SecureString]$APIKey,
        [securestring]$ClientSecret,
        [Int32]$ExpirationTimeSeconds = 60
    )

    $header = @{
        "alg" = "HS256"
        "typ" = "JWT"
    } | ConvertTo-Json

    $headerBytes    = [System.Text.Encoding]::ASCII.GetBytes($header)
    $headerB64S     = [convert]::ToBase64String($headerBytes)

    $expirationTime = [datetime]::now.AddSeconds($ExpirationTimeSeconds)
    $expirationTimeUnix = [math]::Round( ($expirationTime - [datetime]"1970-01-01").TotalMilliSeconds )

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

    return [PSCustomObject]@{
        Type="JWT"
        Token = ConvertTo-SecureString -AsPlainText -Force -String $jwt
        Expires = $expirationTime
    }
}