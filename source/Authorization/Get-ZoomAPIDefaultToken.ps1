function Get-ZoomAPIDefaultToken {
    [CmdletBinding()]
    param()

    try {
        return Get-Variable -Scope Script -Name defaultToken -ValueOnly -ErrorAction Stop
    } catch {
        throw [Exception]::new('No default token set.')
    }

    
}