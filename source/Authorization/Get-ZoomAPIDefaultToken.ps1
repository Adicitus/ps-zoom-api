function Get-ZoomAPIDefaultToken {
    param()

    try {
        return Get-Variable -Scope Script -Name defaultToken -ea Stop -ValueOnly
    } catch {

    }

    
}