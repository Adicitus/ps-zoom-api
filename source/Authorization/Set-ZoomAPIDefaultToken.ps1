function Set-ZoomAPIDefaultToken {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="TokenString", HelpMessage="JWT string.")]
        [string]$JWT,
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="TokenObject", HelpMessage="Zoom API Token object.")]
        [PSCustomObject]$Token
    )

    switch($PSCmdlet.ParameterSetName) {
        TokenString {
            $script:defaultToken = New-ZoomAPIJWTToken $JWT
        }
        TokenObject {
            $script:defaultToken = $Token
        }
    }
}