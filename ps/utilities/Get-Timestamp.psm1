function Get-Timestamp {
    return (Get-Date -Format "HH:mm:ss.fff") + " -"
}

Export-ModuleMember -Function Get-Timestamp
