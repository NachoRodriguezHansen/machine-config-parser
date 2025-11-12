function Get-Timestamp {
    <#
    .SYNOPSIS
    Returns current timestamp in format "HH:mm:ss.fff"
    #>
    return (Get-Date -Format "HH:mm:ss.fff") + " - "
}

Export-ModuleMember -Function Get-Timestamp
