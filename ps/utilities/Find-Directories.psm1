function Find-Directories {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$RegexPattern
    )

    if (-not (Test-Path $Path -PathType Container)) { return @() }

    return Get-ChildItem -Path $Path -Directory | Where-Object { $_.Name -match $RegexPattern }
}

Export-ModuleMember -Function Find-Directories
